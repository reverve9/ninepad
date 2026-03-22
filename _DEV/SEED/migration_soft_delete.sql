-- memos 소프트 딜리트: deleted_at 컬럼 추가
ALTER TABLE memos ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMPTZ DEFAULT NULL;
CREATE INDEX IF NOT EXISTS idx_memos_deleted_at ON memos(deleted_at);
