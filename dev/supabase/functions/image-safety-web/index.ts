// Supabase Edge Function: image-safety-web
// Purpose: Run SafeSearch + Label detection via Google Cloud Vision to moderate images on Web before upload.
// Request JSON: { fileName: string, contentType: string, dataBase64: string }
// Response JSON: { allowed: boolean, reason?: string, labels?: string[] }

type VisionLikelihood =
  | 'UNKNOWN'
  | 'VERY_UNLIKELY'
  | 'UNLIKELY'
  | 'POSSIBLE'
  | 'LIKELY'
  | 'VERY_LIKELY';

interface VisionLabel {
  description?: string;
  score?: number;
}

function likelihoodScore(v?: VisionLikelihood): number {
  switch (v) {
    case 'VERY_LIKELY':
      return 5;
    case 'LIKELY':
      return 4;
    case 'POSSIBLE':
      return 3;
    case 'UNLIKELY':
      return 2;
    case 'VERY_UNLIKELY':
      return 1;
    default:
      return 0;
  }
}

const BLOCK_THRESHOLD = parseInt(Deno.env.get('SAFESEARCH_BLOCK_THRESHOLD') ?? '4'); // LIKELY+
const KEYWORD_BLOCKLIST = (Deno.env.get('LABEL_KEYWORD_BLOCKLIST') ??
  'weapon,gun,rifle,pistol,knife,sword,violence,blood,gore,drug,marijuana,cannabis,cocaine,heroin,meth,alcohol,liquor,smoking,tobacco,explicit,nudity,sex,sexual,porn,racy')
  .split(',')
  .map((s) => s.trim().toLowerCase())
  .filter(Boolean);

function keywordHit(labels: VisionLabel[]): string[] {
  const hits: string[] = [];
  for (const l of labels) {
    const text = (l.description ?? '').toLowerCase();
    if (!text) continue;
    for (const kw of KEYWORD_BLOCKLIST) {
      if (text.includes(kw)) {
        const pct = l.score ? ` ${(l.score * 100).toFixed(0)}%` : '';
        hits.push(`${l.description}${pct}`);
        break;
      }
    }
  }
  return hits;
}

Deno.serve(async (req) => {
  if (req.method !== 'POST') {
    return new Response('Method Not Allowed', { status: 405 });
  }

  try {
    const apiKey = Deno.env.get('VISION_API_KEY');
    if (!apiKey) {
      return new Response(
        JSON.stringify({ allowed: true, reason: 'no_api_key_configured' }),
        { headers: { 'content-type': 'application/json' } },
      );
    }

    const body = await req.json().catch(() => ({}));
    const fileName = body.fileName as string | undefined;
    const contentType = body.contentType as string | undefined;
    const dataBase64 = body.dataBase64 as string | undefined;

    if (!dataBase64) {
      return new Response(
        JSON.stringify({ allowed: false, reason: 'missing_image_data' }),
        { status: 400, headers: { 'content-type': 'application/json' } },
      );
    }

    const payload = {
      requests: [
        {
          image: { content: dataBase64 },
          features: [
            { type: 'SAFE_SEARCH_DETECTION' },
            { type: 'LABEL_DETECTION', maxResults: 10 },
          ],
          imageContext: fileName || contentType ? { languageHints: ['en'] } : undefined,
        },
      ],
    };

    const visionRes = await fetch(
      `https://vision.googleapis.com/v1/images:annotate?key=${apiKey}`,
      {
        method: 'POST',
        headers: { 'content-type': 'application/json' },
        body: JSON.stringify(payload),
      },
    );

    if (!visionRes.ok) {
      return new Response(
        JSON.stringify({ allowed: true, reason: 'vision_error' }),
        { headers: { 'content-type': 'application/json' } },
      );
    }

    const json = await visionRes.json();
    const resp = json?.responses?.[0] ?? {};
    const safe = resp.safeSearchAnnotation ?? {};
    const labels: VisionLabel[] = resp.labelAnnotations ?? [];

    const reasons: string[] = [];
    if (likelihoodScore(safe.adult) >= BLOCK_THRESHOLD) reasons.push('adult');
    if (likelihoodScore(safe.violence) >= BLOCK_THRESHOLD) reasons.push('violence');
    if (likelihoodScore(safe.racy) >= BLOCK_THRESHOLD) reasons.push('racy');
    // Optionally consider medical or spoof categories:
    // if (likelihoodScore(safe.medical) >= BLOCK_THRESHOLD) reasons.push('medical');

    const labelHits = keywordHit(labels);

    if (reasons.length || labelHits.length) {
      return new Response(
        JSON.stringify({
          allowed: false,
          reason: reasons.length
            ? `SafeSearch: ${reasons.join(', ')}`
            : 'Label hits',
          labels: labelHits,
        }),
        { headers: { 'content-type': 'application/json' } },
      );
    }

    return new Response(
      JSON.stringify({ allowed: true, labels: labels.map((l) => l.description).filter(Boolean) }),
      { headers: { 'content-type': 'application/json' } },
    );
  } catch (e) {
    return new Response(
      JSON.stringify({ allowed: true, reason: 'exception' }),
      { headers: { 'content-type': 'application/json' } },
    );
  }
});
