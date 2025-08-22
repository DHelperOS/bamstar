// Supabase 웹 에디터용 최종 스크립트
import { serve } from 'https://deno.land/std@0.177.0/http/server.ts';

// CORS Preflight 요청을 처리하기 위한 헤더 (필수)
const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type'
};

// SHA1 해시 생성 함수
async function generateSha1(message: string): Promise<string> {
  const encoder = new TextEncoder();
  const data = encoder.encode(message);
  const hashBuffer = await crypto.subtle.digest('SHA-1', data);
  const hashArray = Array.from(new Uint8Array(hashBuffer));
  return hashArray.map(b => b.toString(16).padStart(2, '0')).join('');
}

// Supabase Edge Function의 메인 로직
serve(async (req)=>{
  // CORS Preflight 요청(OPTIONS)에 대한 응답을 먼저 처리합니다.
  if (req.method === 'OPTIONS') {
    return new Response('ok', {
      headers: corsHeaders
    });
  }
  try {
    // 1. Supabase Secrets에 저장된 Cloudinary 키 정보를 안전하게 가져옵니다.
    const CLOUD_NAME = Deno.env.get('CLOUDINARY_NAME');
    const API_KEY = Deno.env.get('CLOUDINARY_API_KEY');
    const API_SECRET = Deno.env.get('CLOUDINARY_SECRET');
    
    // Secrets이 설정되지 않은 경우 에러를 반환합니다.
    if (!CLOUD_NAME || !API_KEY || !API_SECRET) {
      throw new Error('Cloudinary environment variables (Secrets) are not set correctly.');
    }

    // 3. Flutter 앱에서 POST 방식으로 보낸 파라미터를 JSON으로 파싱합니다.
    const paramsToSign = await req.json();
    
    // 4. 서명 생성을 위한 파라미터 정렬 및 문자열 생성
    const sortedParams = Object.keys(paramsToSign)
      .sort()
      .map(key => `${key}=${paramsToSign[key]}`)
      .join('&');
    
    // 5. API Secret을 사용하여 서명(signature) 생성
    const stringToSign = sortedParams + API_SECRET;
    const signature = await generateSha1(stringToSign);

    // 6. Flutter 앱에 생성된 서명과 API Key를 응답으로 보내줍니다.
    const responsePayload = {
      signature: signature,
      api_key: API_KEY
    };
    
    return new Response(JSON.stringify(responsePayload), {
      headers: {
        ...corsHeaders,
        'Content-Type': 'application/json'
      },
      status: 200
    });
  } catch (error) {
    // 과정 중 에러가 발생하면 에러 메시지를 응답으로 보냅니다.
    return new Response(JSON.stringify({
      error: error.message
    }), {
      headers: {
        ...corsHeaders,
        'Content-Type': 'application/json'
      },
      status: 500
    });
  }
});
