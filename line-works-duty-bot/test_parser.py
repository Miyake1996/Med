"""当直表パーサーのテスト"""

import unittest
from datetime import date
from parser import parse_duty_schedule, format_schedule_text


class TestParseDutySchedule(unittest.TestCase):

    def test_full_date_with_year(self):
        text = "2025年1月5日 山田太郎"
        entries = parse_duty_schedule(text)
        self.assertEqual(len(entries), 1)
        self.assertEqual(entries[0]["date"], date(2025, 1, 5))
        self.assertEqual(entries[0]["name"], "山田太郎")

    def test_full_date_slash_format(self):
        text = "2025/1/5 山田太郎"
        entries = parse_duty_schedule(text)
        self.assertEqual(len(entries), 1)
        self.assertEqual(entries[0]["date"], date(2025, 1, 5))

    def test_month_day_format(self):
        text = "1月5日 山田太郎"
        entries = parse_duty_schedule(text)
        self.assertEqual(len(entries), 1)
        self.assertEqual(entries[0]["date"].month, 1)
        self.assertEqual(entries[0]["date"].day, 5)

    def test_slash_month_day(self):
        text = "1/5 山田太郎"
        entries = parse_duty_schedule(text)
        self.assertEqual(len(entries), 1)
        self.assertEqual(entries[0]["date"].month, 1)
        self.assertEqual(entries[0]["date"].day, 5)

    def test_date_with_weekday(self):
        text = "1月6日(月) 佐藤次郎"
        entries = parse_duty_schedule(text)
        self.assertEqual(len(entries), 1)
        self.assertEqual(entries[0]["name"], "佐藤次郎")

    def test_day_only_with_month_header(self):
        text = """2025年1月 当直表
5日 山田太郎
6日 佐藤次郎
7日 田中三郎"""
        entries = parse_duty_schedule(text)
        self.assertEqual(len(entries), 3)
        self.assertEqual(entries[0]["date"], date(2025, 1, 5))
        self.assertEqual(entries[2]["date"], date(2025, 1, 7))

    def test_name_with_department(self):
        text = "1月5日 山田(内科)"
        entries = parse_duty_schedule(text)
        self.assertEqual(len(entries), 1)
        self.assertEqual(entries[0]["name"], "山田")
        self.assertEqual(entries[0]["role"], "内科")

    def test_multiple_names_slash_separated(self):
        text = "1月5日 山田/佐藤"
        entries = parse_duty_schedule(text)
        self.assertEqual(len(entries), 2)
        self.assertEqual(entries[0]["name"], "山田")
        self.assertEqual(entries[1]["name"], "佐藤")

    def test_table_format(self):
        text = """2025年2月 当直表
1日 山田太郎
2日 佐藤次郎
3日 田中三郎
4日 鈴木四郎
5日 高橋五郎"""
        entries = parse_duty_schedule(text)
        self.assertEqual(len(entries), 5)
        self.assertEqual(entries[0]["date"], date(2025, 2, 1))
        self.assertEqual(entries[4]["name"], "高橋五郎")

    def test_reiwa_year(self):
        text = """令和7年1月
5日 山田太郎"""
        entries = parse_duty_schedule(text)
        self.assertEqual(len(entries), 1)
        self.assertEqual(entries[0]["date"], date(2025, 1, 5))

    def test_empty_text(self):
        entries = parse_duty_schedule("")
        self.assertEqual(len(entries), 0)

    def test_no_schedule_text(self):
        entries = parse_duty_schedule("これは当直表ではありません")
        self.assertEqual(len(entries), 0)

    def test_sorted_output(self):
        text = """2025年1月
7日 田中三郎
5日 山田太郎
6日 佐藤次郎"""
        entries = parse_duty_schedule(text)
        self.assertEqual(entries[0]["date"].day, 5)
        self.assertEqual(entries[1]["date"].day, 6)
        self.assertEqual(entries[2]["date"].day, 7)

    def test_format_schedule_text(self):
        entries = [
            {"date": date(2025, 1, 5), "name": "山田太郎", "role": "当直"},
            {"date": date(2025, 1, 6), "name": "佐藤次郎", "role": "内科"},
        ]
        text = format_schedule_text(entries)
        self.assertIn("山田太郎", text)
        self.assertIn("佐藤次郎", text)
        self.assertIn("内科", text)
        self.assertIn("2件", text)

    def test_format_empty_schedule(self):
        text = format_schedule_text([])
        self.assertIn("読み取れませんでした", text)


if __name__ == "__main__":
    unittest.main()
