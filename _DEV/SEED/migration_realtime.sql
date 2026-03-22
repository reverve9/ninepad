-- memos, snippets 테이블 Realtime 활성화
ALTER PUBLICATION supabase_realtime ADD TABLE memos;
ALTER PUBLICATION supabase_realtime ADD TABLE snippets;
