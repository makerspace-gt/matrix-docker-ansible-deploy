rm .git/hooks/pre-push

ln -sf ../../hooks/post-update .git/hooks/post-update
ln -sf ../../hooks/pre-commit .git/hooks/pre-commit