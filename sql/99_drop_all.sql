-- Cleanup script: drop all schemas & tables if needed
Drop Schema If Exists staging Cascade;
Drop Schema If Exists core Cascade;
Drop Schema If Exists ref Cascade;
