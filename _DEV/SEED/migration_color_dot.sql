-- memos 테이블에 color_dot 컬럼 추가
ALTER TABLE memos ADD COLUMN IF NOT EXISTS color_dot TEXT DEFAULT '#1C2B4A';
