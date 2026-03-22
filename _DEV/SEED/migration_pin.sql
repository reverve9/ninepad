-- memos에 핀 고정 컬럼 추가
ALTER TABLE memos ADD COLUMN IF NOT EXISTS is_pinned BOOLEAN NOT NULL DEFAULT false;
CREATE INDEX IF NOT EXISTS idx_memos_pinned ON memos(is_pinned);

-- snippets 테이블은 더 이상 사용하지 않음 (필요시 삭제)
-- DROP TABLE IF EXISTS snippets;
