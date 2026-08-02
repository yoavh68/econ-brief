#!/usr/bin/env bash
# פרסום דוח יומי חדש לאתר.
#
#   ./publish.sh <קובץ-הדוח.html> <YYYY-MM-DD> "<כותרת ליום הזה>"
#
# מה הסקריפט עושה:
#   1. מעתיק את הדוח ל-<YYYY-MM-DD>.html (קישור קבוע) וגם ל-index.html (עמוד הבית)
#   2. מוסיף שורה חדשה בראש רשימת הארכיון ב-archive.html
#   3. מבצע commit ו-push — האתר מתעדכן תוך דקה
set -euo pipefail

SRC="${1:?חסר: נתיב לקובץ הדוח}"
DATE="${2:?חסר: תאריך בפורמט YYYY-MM-DD}"
HEAD="${3:?חסר: כותרת קצרה לדוח}"

cd "$(dirname "$0")"

[[ "$DATE" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]] || { echo "תאריך לא תקין: $DATE"; exit 1; }
[[ -f "$SRC" ]] || { echo "לא נמצא קובץ: $SRC"; exit 1; }

cp "$SRC" "$DATE.html"
cp "$SRC" "index.html"

# תאריך בעברית לתצוגה בארכיון
DISPLAY=$(date -d "$DATE" '+%-d' 2>/dev/null || echo "$DATE")
MONTHS=(ינואר פברואר מרץ אפריל מאי יוני יולי אוגוסט ספטמבר אוקטובר נובמבר דצמבר)
DAYS=("יום ראשון" "יום שני" "יום שלישי" "יום רביעי" "יום חמישי" "יום שישי" "שבת")
MI=$(( 10#$(date -d "$DATE" '+%m') - 1 ))
DI=$(date -d "$DATE" '+%w')
LABEL="${DAYS[$DI]}, $DISPLAY ב${MONTHS[$MI]} $(date -d "$DATE" '+%Y')"

ENTRY="  <li>\n    <a href=\"$DATE.html\">\n      <span class=\"date\">$LABEL</span>\n      <span class=\"head\">$HEAD</span>\n    </a>\n  </li>"

# החדש ביותר תמיד ראשון ברשימה
if grep -q "href=\"$DATE.html\"" archive.html; then
  echo "הדוח ל-$DATE כבר קיים בארכיון — מדלג על ההוספה."
else
  perl -0pi -e "s|(<ul class=\"arch\">\n)|\$1$ENTRY\n|" archive.html
fi

git add -A
git commit -q -m "דוח כלכלי $DATE" || { echo "אין שינויים לפרסום."; exit 0; }
git push -q origin HEAD
echo "פורסם: $DATE.html"
