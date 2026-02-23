import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.7"

const corsHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

Deno.serve(async (req) => {
    if (req.method === 'OPTIONS') {
        return new Response('ok', { headers: corsHeaders })
    }

    try {
        const supabaseUrl = Deno.env.get('SUPABASE_URL')!;
        const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
        const supabase = createClient(supabaseUrl, supabaseServiceKey);

        console.log('Cleanup: Scanning for expired 10s videos...');

        // Find videos older than 24 hours
        const { data: posts, error: fetchError } = await supabase
            .from('posts')
            .select('id, media_url, content')
            .eq('media_type', 'video_10s')
            .lte('created_at', new Date(Date.now() - 24 * 60 * 60 * 1000).toISOString())
            .not('media_url', 'is', null);

        if (fetchError) throw fetchError;

        if (!posts || posts.length === 0) {
            console.log('No expired videos found.');
            return new Response(JSON.stringify({ message: 'No expired videos found' }), {
                headers: { ...corsHeaders, 'Content-Type': 'application/json' },
                status: 200,
            });
        }

        console.log(`Found ${posts.length} expired videos. Starting cleanup...`);

        let deletedCount = 0;
        for (const post of posts) {
            try {
                const urlParts = post.media_url.split('/temp_videos/');
                if (urlParts.length < 2) {
                    console.warn(`Malformed media_url for post ${post.id}: ${post.media_url}`);
                    continue;
                }

                const filePath = urlParts[1];

                // 1. Delete from Storage
                const { error: storageError } = await supabase.storage
                    .from('temp_videos')
                    .remove([filePath]);

                if (storageError && !storageError.message.includes('not found')) {
                    console.error(`Storage error for ${filePath}:`, storageError);
                    continue;
                }

                // 2. Update DB post content and remove media_url
                const { error: updateError } = await supabase
                    .from('posts')
                    .update({
                        media_url: null,
                        content: post.content ? `${post.content}\n\n[वीडियो हटा दिया गया है / Video Expired]` : '[वीडियो हटा दिया गया है / Video Expired]'
                    })
                    .eq('id', post.id);

                if (updateError) {
                    console.error(`Database update error for post ${post.id}:`, updateError);
                    continue;
                }

                deletedCount++;
                console.log(`Cleaned up post ${post.id} and file ${filePath}`);
            } catch (e) {
                console.error(`Error processing post ${post.id}:`, e);
            }
        }

        return new Response(JSON.stringify({ message: 'Cleanup complete', deletedCount }), {
            headers: { ...corsHeaders, 'Content-Type': 'application/json' },
            status: 200,
        });

    } catch (error) {
        console.error('Fatal cleanup error:', error);
        return new Response(JSON.stringify({ error: error.message }), {
            headers: { ...corsHeaders, 'Content-Type': 'application/json' },
            status: 500,
        });
    }
});
