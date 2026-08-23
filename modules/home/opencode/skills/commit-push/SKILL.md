---
name: commit-push
description: Use when the user asks to commit and push changes (e.g. "commit and push", "create a commit and push it", "push my changes"). Reviews the working tree, writes a detailed conventional commit message, commits, and pushes to the remote.
---

# Commit & Push

Создаёт подробный коммит в стиле Conventional Commits и пушит его в remote —
только когда пользователь явно об этом попросил.

## Порядок действий

1. **Осмотреть состояние репозитория** — выполнить параллельно:
   - `git status` — staged, unstaged и untracked файлы
   - `git diff` и `git diff --staged` — что реально изменилось
   - `git log --oneline -10` — стиль сообщений в этом репозитории
   - `git branch --show-current` — текущая ветка

2. **Проанализировать изменения** перед написанием сообщения:
   - Если изменений нет — сообщить пользователю и остановиться. Пустые
     коммиты не создавать.
   - Что изменилось и зачем? Сгруппировать связанные изменения в одно
     логическое целое.
   - Если в дереве несколько несвязанных изменений — закоммитить их одним
     коммитом, сгруппировав описание в теле сообщения.
   - НИКОГДА не коммитить секреты, credentials, `.env` и файлы, которые
     пользователь не просил. Перед коммитом проверить diff на маркеры
     конфликтов (`<<<<<<<`, `=======`, `>>>>>>>`).

3. **Написать подробное сообщение Conventional Commits** — всегда на
   английском языке:

   ```
   <type>(<scope>): <short summary in imperative mood>

   <body: what changed and why, wrapped at 72 chars>

   <footers>
   ```

   - **type**: `feat` (новая функциональность), `fix` (исправление бага),
     `docs`, `style` (только форматирование), `refactor` (без изменения
     поведения), `perf`, `test`, `build` (система сборки/зависимости), `ci`,
     `chore` (инструменты, без изменения src), `revert`.
   - **scope**: необязательный, затронутый модуль/область, например `(nix)`,
     `(nvim)`, `(hyprland)`. Опустить, если явного scope нет.
   - **subject**: повелительное наклонение ("add", а не "added"), строчными
     буквами, без точки в конце, желательно ≤ 50 символов, жёсткий лимит 72.
   - **body**: обязателен для нетривиальных изменений. Описывать ЧТО изменено
     и ЗАЧЕМ, а не как. Списки допустимы. Указывать пути файлов, если помогает.
   - **footers**: `BREAKING CHANGE: ...` (или `!` после type/scope) для
     ломающих изменений; `Refs: #123` / `Closes: #123` для ссылок на задачи.
   - Если стиль репозитория (из `git log`) отличается — следовать ему, но
     язык сообщений всегда английский.

4. **Стейдж и коммит**:
   - Стейджить только нужные файлы: `git add <file1> <file2> ...`.
     Избегать `git add -A` / `git add .`, если пользователь не просил и diff
     не проверен.
   - Коммитить через HEREDOC, чтобы сохранить многострочное сообщение:

     ```bash
     git commit -m "$(cat <<'EOF'
     feat(nvim): add treesitter textobjects plugin

     Adds nvim-treesitter-textobjects to enable selecting and moving
     around functions, classes, and parameters with vim motions.

     - keymaps under ]f/[f for function navigation
     - `af`/`if` textobjects for around/inside function
     EOF
     )"
     ```

   - Если упали pre-commit хуки — исправить причину и закоммитить заново.
     НЕ использовать `--no-verify` без явной просьбы пользователя.
   - НЕ использовать `--amend` без явной просьбы пользователя.

5. **Пуш в remote**:
   - `git push`, если ветка уже отслеживает удалённую.
   - `git push -u origin <branch>`, если upstream ещё не настроен.
   - Если пуш отклонён (non-fast-forward) — НЕ делать force-push. Сообщить
     пользователю и предложить сначала pull/rebase.
   - Никогда не использовать `--force` без явной просьбы пользователя.

6. **Отчёт о результате**: показать новый коммит (`git log -1 --stat`) и
   подтвердить успешный пуш (имя remote и ветки).
