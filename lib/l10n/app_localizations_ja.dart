// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get app_name => 'VitaCase';

  @override
  String get skip => 'スキップ';

  @override
  String get next => '次へ';

  @override
  String get start => '開始';

  @override
  String get back => '戻る';

  @override
  String get save => '保存';

  @override
  String get cancel => 'キャンセル';

  @override
  String get error => 'エラー';

  @override
  String get success => '成功';

  @override
  String get loading => '読み込み中...';

  @override
  String get active => 'アクティブ';

  @override
  String get inactive => '非アクティブ';

  @override
  String get premium_feature => 'プレミアム機能 🌟';

  @override
  String get premium_required_desc => 'アプリロックにはプレミアムメンバーシップが必要です。';

  @override
  String get go_premium => 'プレミアムに行く';

  @override
  String get index => '索引';

  @override
  String get view_weekly => '毎週';

  @override
  String get view_monthly => '毎月';

  @override
  String get phone_country_code => 'コード';

  @override
  String get coming_soon => '近日公開';

  @override
  String get coming_soon_desc => 'この機能は次回のアップデートで利用できるようになる予定です。';

  @override
  String tap_for_test(int count) {
    return 'テスト通知を行うには $count をさらに何回もタップします';
  }

  @override
  String get unit_ml => 'ml';

  @override
  String get unit_l => 'L';

  @override
  String get metric_water => '水';

  @override
  String get metric_steps => 'ステップ';

  @override
  String get metric_sleep => '寝る';

  @override
  String get metric_heart_rate => '心拍';

  @override
  String get unit_steps => '歩';

  @override
  String get unit_hours => '時間';

  @override
  String get unit_bpm => 'BPM';

  @override
  String get quick_actions_visibility => 'クイックアクセスの可視性';

  @override
  String get personal_notes => '個人的なメモ';

  @override
  String get save_and_list => '保存してリストする';

  @override
  String get doctor_info => '医師情報';

  @override
  String get add_doctor_desc => 'すぐにアクセスできるように、医師の連絡先情報を保管してください。';

  @override
  String get basic_info => '基本情報';

  @override
  String get institution_contact => '機関と連絡先';

  @override
  String get notes_bio => 'メモと略歴';

  @override
  String get unknown => '未知';

  @override
  String get hospital_clinic_name => '病院・クリニック名';

  @override
  String get phone_number => '電話番号';

  @override
  String get email_address => '電子メールアドレス';

  @override
  String get address => '住所';

  @override
  String get emergency_info => '緊急情報';

  @override
  String get emergency_contact_name => '緊急連絡先（名前）';

  @override
  String get emergency_contact_phone => '緊急連絡先（電話）';

  @override
  String get blood_type => '血液型';

  @override
  String get blood_unknown => '未知';

  @override
  String get profile_updated => 'プロフィール更新しました！ ✅';

  @override
  String get please_enter_name => '名前を入力してください';

  @override
  String get continue_btn => '続ける';

  @override
  String get let_start => '始めましょう';

  @override
  String get ob_1_title => 'ビタケース';

  @override
  String get ob_1_subtitle => 'すべてのファイルを 1 か所に';

  @override
  String get ob_1_desc => '書類、予定、薬などを安全に保管し、常に持ち歩きましょう。';

  @override
  String get ob_2_title => 'すべてのファイルを整理する';

  @override
  String get ob_2_desc => 'ドキュメントをアップロードして分類し、簡単に管理します。';

  @override
  String get ob_3_title => '予定を保存する';

  @override
  String get ob_3_desc => 'すべての予定を 1 か所に保管し、リマインダーで予定を忘れることはありません。';

  @override
  String get ob_4_title => '薬を保存して追跡する';

  @override
  String get ob_4_desc => '薬と使用時間を記録し、リマインダーを付けて定期的に使用することを忘れないでください。';

  @override
  String get ob_5_title => '救って、失わないでください';

  @override
  String get ob_5_desc => '予約や薬を安全に保ち、リラックスした状態を保ちます。';

  @override
  String get ob_feature_1_title => '安全なストレージ';

  @override
  String get ob_feature_1_desc => 'あなたのデータは暗号化されており、あなただけのものです。';

  @override
  String get ob_feature_2_title => 'リマインダー';

  @override
  String get ob_feature_2_desc => '予約時間と薬の時間を忘れないでください。';

  @override
  String get ob_feature_3_title => 'どこからでもアクセス';

  @override
  String get ob_feature_3_desc => 'いつでも好きなときにすべての情報にアクセスできます。';

  @override
  String get hi => 'こんにちは';

  @override
  String get good_morning => 'おはよう';

  @override
  String get good_afternoon => 'こんにちは';

  @override
  String get good_evening => 'こんばんは';

  @override
  String get good_night => 'おやすみ';

  @override
  String get synced => '同期済み';

  @override
  String get guest_mode => 'ゲストモードがアクティブです';

  @override
  String get guest_desc => 'データはローカルのみです。バックアップするアカウントを作成します。';

  @override
  String get guest_user => 'ゲストユーザー';

  @override
  String get all_records => '安全なアーカイブ';

  @override
  String get vault_is_empty => '保管庫の準備ができました';

  @override
  String get vault_desc => '最も重要な記録をプライベートな聖域に保管し、整理します。';

  @override
  String get quick_access => 'クイックアクセス';

  @override
  String get steps => '歩数';

  @override
  String get heart => '心拍';

  @override
  String get sleep => '睡眠';

  @override
  String get water => '水分';

  @override
  String get bpm => 'BPM';

  @override
  String get hours => '営業時間';

  @override
  String get ml => 'ML';

  @override
  String get home => 'ホーム';

  @override
  String get vault => '保管庫';

  @override
  String get explore => '探索';

  @override
  String get appointments => '予定';

  @override
  String get profile => 'プロフィール';

  @override
  String get pharmacies => '薬局';

  @override
  String get medicines => '薬';

  @override
  String get health_data => '健康データ';

  @override
  String get important_info => '重要情報';

  @override
  String get create_profile => 'プロフィールを作成';

  @override
  String get profile_desc => '体験をパーソナライズするために、いくつかの情報が必要です。';

  @override
  String get full_name => '氏名';

  @override
  String get gender => '性別';

  @override
  String get birth_date => '生年月日';

  @override
  String get date_format_hint => 'DD.MM.YYYY';

  @override
  String get save_continue => '保存して続行';

  @override
  String get security_badge_label => 'VITACASE 高度な暗号化 v2.4';

  @override
  String get health_stats => 'ヘルスハブ';

  @override
  String get health_stats_desc => '毎日の健康に関する包括的なサマリー。';

  @override
  String get recent_activity => '最近の活動';

  @override
  String get no_health_records => 'まだ記録がありません。';

  @override
  String get add_health_data => '健康データを追加';

  @override
  String get step_unit => 'ステップ';

  @override
  String get privacy_guarantee => 'あなたのデータは安全です';

  @override
  String get privacy_box_desc => 'あなたの情報は安全に保管され、決して共有されません。';

  @override
  String get privacy_box_warning =>
      'データは非公開であり、デバイスに安全に保存されます。機密性の高い情報のアップロードは避けてください。あなたは保存したデータに対して責任を負います。';

  @override
  String get docs_secure_storage_title => '安全なローカルストレージ 🔒';

  @override
  String get docs_secure_storage_desc => 'データはデバイス上に残ります';

  @override
  String get docs_sensitive_warning =>
      '機密性の高い情報の保存は避けてください。あなたは自分のデータに対して責任を負います。';

  @override
  String get gender_female => '女性';

  @override
  String get gender_male => '男性';

  @override
  String get gender_other => 'その他';

  @override
  String get appearance => '外観';

  @override
  String get theme_settings => 'テーマの設定';

  @override
  String get app_settings => 'アプリの設定';

  @override
  String get text_size => '文字サイズ';

  @override
  String get quick_actions => 'クイックアクション';

  @override
  String get data_security => 'データとセキュリティ';

  @override
  String get app_lock => 'アプリロック';

  @override
  String get backup_zip => 'バックアップ(ZIP)';

  @override
  String get import_backup => 'バックアップを復元する';

  @override
  String get import_desc => 'ZIPバックアップファイルをインポートする';

  @override
  String get export_desc => '書類のエクスポート';

  @override
  String get emergency_contact => '緊急連絡先';

  @override
  String get daily_step_goal => '毎日の歩数目標';

  @override
  String get support_legal => 'サポートと法的事項';

  @override
  String get help_center => 'ヘルプセンター';

  @override
  String get report_issue => 'バグ、提案、リクエストを送信する';

  @override
  String get privacy_policy => 'プライバシーポリシー';

  @override
  String get terms_conditions => '利用規約';

  @override
  String get legal_disclaimer => '法的免責事項';

  @override
  String get legal => '法律上の';

  @override
  String get lock_gate_title => 'VitaCase がロックされました';

  @override
  String get lock_gate_desc => '安全な文書保管庫にアクセスするには認証を行ってください。';

  @override
  String get lock_gate_unlock => '生体認証によるロック解除';

  @override
  String get lock_set_pin => '安全なPINを設定';

  @override
  String get lock_confirm_pin => 'PINを確認';

  @override
  String get lock_pin_mismatch => 'PINが一致しません。もう一度お試しください。';

  @override
  String get lock_pin_incorrect => '間違ったPIN';

  @override
  String get lock_use_biometrics => '生体認証を使用する';

  @override
  String lock_too_many_attempts(int seconds) {
    return '試行回数が多すぎます。 $seconds秒後にもう一度お試しください。';
  }

  @override
  String get lock_timeout_instant => 'インスタント';

  @override
  String get lock_timeout_1min => '1分';

  @override
  String get lock_timeout_5min => '5分';

  @override
  String get lock_timeout_15min => '15分';

  @override
  String get lock_timeout => 'ロックタイムアウト';

  @override
  String get change_pin => 'PINの変更';

  @override
  String get biometric_login => '生体認証ログイン';

  @override
  String get biometric_unavailable => 'このデバイスでは生体認証は利用できません。';

  @override
  String get digits => '数字';

  @override
  String get lock_skip_desc => '後で設定から設定できます。';

  @override
  String get setup_pin_later => '後で「設定」から設定する';

  @override
  String get skip_pin_setup => 'スキップ';

  @override
  String get setup_app_lock => 'アプリロックを設定';

  @override
  String get setup_app_lock_desc => '6桁のPINでデータを保護します。';

  @override
  String get step_profile => 'プロフィール';

  @override
  String get step_security => 'セキュリティ';

  @override
  String get daily_missions => 'デイリーミッション';

  @override
  String get mission_doc_daily => '1 ドキュメントを追加';

  @override
  String get mission_ad_daily => '1 件の広告を見る';

  @override
  String get mission_app_daily => 'スケジュール 1 予約';

  @override
  String get mission_med_daily => '薬を1つ追加';

  @override
  String get export_data_zip => 'データのエクスポート (.zip)';

  @override
  String get clear_all_data => 'すべてのデータをクリア';

  @override
  String get quick_actions_desc => 'ダッシュボード上のクイックショートカット';

  @override
  String get app_section => 'アプリ';

  @override
  String get premium_required => 'プレミアムが必要です';

  @override
  String get logout => 'ログアウト';

  @override
  String get logout_confirm => 'ログアウトしてもよろしいですか?';

  @override
  String get yes_logout => 'はい、ログアウトします';

  @override
  String get version => 'バージョン';

  @override
  String get my_medicines => '私の薬';

  @override
  String med_count_desc(int count) {
    return '今日の薬は $count 個あります。';
  }

  @override
  String get low_stock_warning => '在庫僅少';

  @override
  String critical_level(String name) {
    return '$name の重大レベル。';
  }

  @override
  String get refill => 'リフィル';

  @override
  String get intake_chart => '摂取コンプライアンスチャート';

  @override
  String weekly_avg(int perc) {
    return '週平均: $perc%';
  }

  @override
  String get medicine_cabinet => '薬品棚';

  @override
  String get active_inventory => 'アクティブな在庫';

  @override
  String get add => '追加';

  @override
  String get daily_routine => '日課';

  @override
  String get morning => '朝';

  @override
  String get afternoon => '午後';

  @override
  String get night => '夜';

  @override
  String get med_cabinet_add => '新しい医学';

  @override
  String stock_left(int count) {
    return '$count 左';
  }

  @override
  String get vital_signs => 'バイタルサイン';

  @override
  String get daily_goals => '毎日の目標';

  @override
  String get activity => '活動';

  @override
  String get step_counter => 'ステップカウンター';

  @override
  String get water_tracker => '水分追跡装置';

  @override
  String get safety_footer_med =>
      'VitaCase は管理ツールです。医学的なアドバイスや推奨用量を提供するものではありません。必ず医師の指示に従ってください。';

  @override
  String get safety_footer_health =>
      '健康データは情報提供のみを目的としています。診断については専門家にご相談ください。';

  @override
  String get medical_device_warning => 'VitaCaseは医療機器ではありません。必ず専門家にご相談ください。';

  @override
  String get management_tool_warning => 'VitaCaseは管理ツールであり、診断サービスではありません。';

  @override
  String get hint_name => '例えばジョン・ドゥ';

  @override
  String get hint_emergency => '氏名 / 電話番号';

  @override
  String get docs_title => 'ドキュメント';

  @override
  String get docs_search_hint => '保管庫を検索します (文書、メモ、ID など)。';

  @override
  String get docs_info_secure => 'あなたの文書は安全に保管され、あなた専用です。';

  @override
  String get docs_info_encrypted => 'データは暗号化によってローカルで保護されます。';

  @override
  String get docs_sort_all => '全て';

  @override
  String get docs_sort_newest => '最新';

  @override
  String get docs_sort_oldest => '最古の';

  @override
  String get docs_empty_title => 'ここは空いています';

  @override
  String get docs_empty_subtitle => '最初のドキュメントを追加して、Vault の整理を始めます。';

  @override
  String get docs_category_health => '健康';

  @override
  String get docs_category_identity => '身分証明';

  @override
  String get docs_category_finance => '金融';

  @override
  String get docs_category_legal => '法務';

  @override
  String get docs_category_notes => 'メモ';

  @override
  String get docs_category_other => 'その他';

  @override
  String get docs_loading_open => '安全なファイルを開いています...';

  @override
  String get docs_loading_decrypt => 'AES-256 復号化';

  @override
  String get docs_add_btn => 'ドキュメントを追加';

  @override
  String get docs_add_title => 'ドキュメントを追加';

  @override
  String get docs_add_source => '情報源/機関 (オプション)';

  @override
  String get docs_add_person => '関係者・詳細';

  @override
  String get docs_add_cat => 'カテゴリ';

  @override
  String get docs_add_type => '文書の種類';

  @override
  String get docs_add_note => '注記 (オプション)';

  @override
  String get docs_add_secure => 'この情報は AES-256 で暗号化されます。';

  @override
  String get docs_add_pick_diff => '別のファイルを選択してください';

  @override
  String get docs_success => 'ドキュメントが正常に保存されました！';

  @override
  String get docs_error_save => 'ドキュメントの保存に失敗しました';

  @override
  String get docs_error_pick => 'ファイルを選択してください';

  @override
  String get docs_error_source => '健康書類には機関名が必要です';

  @override
  String get docs_error_size => 'ファイルサイズは最大10MBである必要があります';

  @override
  String get docs_add_pick => 'ドキュメント / 画像を選択';

  @override
  String get docs_add_file_selected => '選択したファイル';

  @override
  String get docs_action_delete => '消去';

  @override
  String get docs_no_results => '結果が見つかりませんでした';

  @override
  String get docs_no_matching => '条件に一致する文書はありません';

  @override
  String get docs_try_different => '別のキーワードで検索してみてください。';

  @override
  String get docs_no_filter_match => '選択したフィルターのドキュメントが見つかりませんでした。';

  @override
  String get docs_show_all => 'すべて表示';

  @override
  String get privacy_warning_title => 'プライバシーに関する警告';

  @override
  String get privacy_warning_desc =>
      '機密情報およびアップロードされたドキュメントに対する単独の責任は、すべてユーザーに帰属します。危険性の高いデータを保存する場合は注意してください。';

  @override
  String get hint_select => '選択';

  @override
  String get hint_institution => '例えば市立病院、銀行、公証人';

  @override
  String get hint_person_detail => '例えばメフメット博士、アーメット弁護士、税金番号';

  @override
  String get hint_add_note => 'メモを追加...';

  @override
  String get docs_category_prescriptions => '処方箋';

  @override
  String get docs_category_reports => '報告';

  @override
  String get docs_category_test_results => '試験結果';

  @override
  String get docs_category_images => '医用画像';

  @override
  String get upcoming_appointment => '今後の予定';

  @override
  String get my_appointments => '私の予定';

  @override
  String get weekly => '毎週';

  @override
  String get monthly => '毎月';

  @override
  String get no_more_appointments => 'これ以上の予定は見つかりません。';

  @override
  String get add_new_appointment => '新しい予定を追加';

  @override
  String get join_meeting => 'ミーティングに参加する';

  @override
  String get location => '場所';

  @override
  String get today => '今日';

  @override
  String get tomorrow => '明日';

  @override
  String get health_trend_desc => '7日間の健康傾向';

  @override
  String get all_records_title => 'すべての記録';

  @override
  String get personal_health_data => '個人の健康データ';

  @override
  String get personal_info => '個人情報';

  @override
  String get account_settings => 'アカウント設定';

  @override
  String get emergency_card => '緊急カード';

  @override
  String get allergies => 'アレルギー';

  @override
  String get none => 'なし';

  @override
  String get not_added => '追加されていません';

  @override
  String get active_goals => 'アクティブな目標';

  @override
  String get daily_steps => '毎日の歩数';

  @override
  String get water_intake => '水分摂取量';

  @override
  String get liter_unit => 'リットル';

  @override
  String get speed_up => 'スピードアップ';

  @override
  String get stay_fresh => '新鮮さを保つ';

  @override
  String get target_label => 'ターゲット';

  @override
  String get logout_desc_safe => 'ログアウトしてもよろしいですか?データはデバイスに安全に保存されたままになります。';

  @override
  String get years_old => '歳';

  @override
  String get add_medicine => '薬を追加';

  @override
  String get medicine_name => '薬の名前';

  @override
  String get med_name_hint => '例えばアスピリン';

  @override
  String get frequency => '頻度';

  @override
  String get reminder_times => 'リマインダー時間';

  @override
  String get current_stock => '現在の在庫';

  @override
  String get stock_warning => '在庫が5個を下回った場合はお知らせします。';

  @override
  String get hero_health_tip => 'あなたの健康のために';

  @override
  String get hero_consistency => '一貫性が鍵です';

  @override
  String get med_added_success => '薬が正常に追加されました！';

  @override
  String get med_name_error => '薬の名前を入力してください';

  @override
  String get custom_freq_title => 'カスタム周波数';

  @override
  String get custom_freq_hint => '例えば2週間ごと';

  @override
  String get apply => '適用する';

  @override
  String get daily => '毎日';

  @override
  String get custom => 'カスタム';

  @override
  String get tablet => '錠剤';

  @override
  String get syrup => 'シロップ(ml)';

  @override
  String get dose => '用量';

  @override
  String get capsule => 'カプセル';

  @override
  String get drops => 'ドロップ';

  @override
  String get limit_title => 'ストレージがいっぱいです! 🚀';

  @override
  String limit_desc(int count) {
    return '現在の制限は $count ドキュメントです。短いビデオを見て、さらに 5 スロットを獲得しますか?';
  }

  @override
  String limit_desc_meds(int count) {
    return '現在の制限は $count 個の医薬品です。短いビデオを見て、さらに 5 スロットを獲得しますか?';
  }

  @override
  String limit_desc_appts(int count) {
    return '現在の制限は $count 件の予定です。短いビデオを見て、さらに 5 スロットを獲得しますか?';
  }

  @override
  String get limit_close => '近い';

  @override
  String get limit_reward_btn => '見て得する';

  @override
  String get limit_reward_success => 'おめでとう！ +10 ドキュメントスロットが追加されました。';

  @override
  String get limit_ad_free_info => '安全でプライベートなローカルストレージ 🛡️';

  @override
  String limit_slots_used(int count, int limit) {
    return '$count/$limit スロットが使用されています';
  }

  @override
  String get lock_title => 'VitaCase がロックされました';

  @override
  String get lock_subtitle => 'アクセスするには確認してください';

  @override
  String get unlock => 'ロックを解除する';

  @override
  String get bmi_underweight => '低体重';

  @override
  String get bmi_normal => '通常（理想）';

  @override
  String get bmi_overweight => '太りすぎ';

  @override
  String get bmi_obese => '肥満';

  @override
  String get page_not_found => 'ページが見つからないか、エラーが発生しました。';

  @override
  String get legal_onboarding_clause =>
      'VitaCase がオフラインファーストの保管庫であることを認めます。私のデバイスとその中に保存されている機密の健康データのセキュリティについては私が単独で責任を負います。';

  @override
  String get delete_all_data => 'すべてのデータを削除する';

  @override
  String get wipe_confirm_1 =>
      'すべてのデータ、ドキュメント、設定は完全に削除されます。この操作は元に戻すことができません。続けますか?';

  @override
  String get wipe_confirm_2 => '本当に大丈夫ですか?すべての医療アーカイブと暗号化された記録はこのデバイスから消去されます。';

  @override
  String get final_warning => 'セキュリティに関する最終警告';

  @override
  String get wipe_btn_final => 'はい、すべて削除します';

  @override
  String get all_data_deleted => 'すべてのデータが消去されました。アプリが再起動されます。';

  @override
  String get edit => '編集';

  @override
  String get delete => '消去';

  @override
  String get theme_selection_title => 'テーマの選択';

  @override
  String get watch_ad => '広告を見る';

  @override
  String get verify_sentry => 'Sentry の統合を確認する';

  @override
  String get edit_panel_soon => '編集パネルは近日公開予定です。';

  @override
  String get add_new_record => '新しいレコードを追加';

  @override
  String get category => 'カテゴリ';

  @override
  String get fill_required_fields => '必須フィールドに入力してください';

  @override
  String get error_doctor_data => '医師名と診療科を入力してください';

  @override
  String get error_appointment_data => 'タイトルと病院/センターのフィールドを入力してください';

  @override
  String get appointment_reminder_title => '予約のリマインダー';

  @override
  String appointment_reminder_body(String time, String doctor, String dept) {
    return '$time: $doctor ($dept) に予定があります';
  }

  @override
  String get select_language => '言語を選択';

  @override
  String get ok => 'OK';

  @override
  String get text_size_small => '小さい';

  @override
  String get text_size_medium => '中くらい';

  @override
  String get text_size_large => '大きい';

  @override
  String get support_contact => 'サポート チームに連絡するには: limanexsoftware@outlook.com';

  @override
  String get quick_actions_optimized => 'クイック アクションは、プロファイルに合わせてすでに最適化されています。';

  @override
  String get medication_reminder => '服薬リマインダー';

  @override
  String medication_reminder_body(String name, String dose) {
    return '$name ($dose) の時間';
  }

  @override
  String get no_doctors_found => '一致する医師が見つかりませんでした';

  @override
  String get clear_filters => 'フィルターをクリアする';

  @override
  String get verified => '確認済み';

  @override
  String get height_label => '身長';

  @override
  String get weight_label => '重さ';

  @override
  String get age_label => '年';

  @override
  String get identity_contact => '身元と連絡先';

  @override
  String get id_number => 'ID番号';

  @override
  String get update_info => 'アップデート情報';

  @override
  String get vita_badge => 'VitaCase ユーザー';

  @override
  String get default_job => 'フリーランス / 健康愛好家';

  @override
  String get blood_type_val => 'Rh+';

  @override
  String get clinical_note => '臨床ノート';

  @override
  String get last_control => 'ラストコントロール';

  @override
  String get bmi_ideal => '理想的な体重の範囲';

  @override
  String get medical_info_desc_empty => '重要な医療情報をここに保管して、いつでも持ち運べます。';

  @override
  String get category_critical => '重要な情報';

  @override
  String get category_important => '重要な注意事項';

  @override
  String get category_general => '一般情報';

  @override
  String get medical_info_desc => 'あなたの健康にとって重要なすべての医療記録。';

  @override
  String get title => 'タイトル';

  @override
  String get description => '説明';

  @override
  String get icon => 'アイコン';

  @override
  String get save_record => '記録の保存';

  @override
  String get critical => '致命的';

  @override
  String get important => '重要';

  @override
  String get general => '一般的な';

  @override
  String get theme_unlock_desc => 'このテーマを試すか、広告を視聴して永久にロックを解除することができます。';

  @override
  String get theme_previewing => 'テーマは 10 秒間プレビューされています...';

  @override
  String get preview_10s => 'プレビュー (10 秒)';

  @override
  String get congratulations => 'おめでとう！';

  @override
  String get theme_unlocked_success => '新しいテーマのロックが解除されました。';

  @override
  String get please_enter_at_least_one_data => '少なくとも 1 つのデータ ポイントを入力してください。';

  @override
  String get data_saved_success => 'データは正常に保存されました。';

  @override
  String get add_data => 'データの追加';

  @override
  String get save_data => 'セーブデータ';

  @override
  String get today_summary => '今日のまとめ';

  @override
  String get target_water => '対象水';

  @override
  String get target_steps => '目標ステップ';

  @override
  String get add_doctor => '医師を追加';

  @override
  String get doctor_name_surname => '医師名 姓';

  @override
  String get specialty_department => '専門・学科';

  @override
  String get new_record => '新記録';

  @override
  String get appointment_updated => '予定が更新されました。';

  @override
  String get appointment_added => '予定が正常に追加されました。';

  @override
  String get edit_appointment => '予定を編集する';

  @override
  String get appointment_title => '予定タイトル';

  @override
  String get importance_level => '重要度';

  @override
  String get notes_optional => '注記 (オプション)';

  @override
  String get address_department => '完全な住所/所属';

  @override
  String get select_category => 'カテゴリの選択';

  @override
  String get category_meeting => 'ミーティング';

  @override
  String get category_reminder => 'リマインダー';

  @override
  String get category_other => '他の';

  @override
  String get app_slogan => 'デジタルサンクチュアリ';

  @override
  String get day_monday_short => '月';

  @override
  String get day_tuesday_short => '火曜日';

  @override
  String get day_wednesday_short => '水';

  @override
  String get day_thursday_short => '木';

  @override
  String get day_friday_short => '金曜日';

  @override
  String get day_saturday_short => '土';

  @override
  String get day_sunday_short => '太陽';

  @override
  String get day_monday_very_short => 'M';

  @override
  String get day_tuesday_very_short => 'T';

  @override
  String get day_wednesday_very_short => 'W';

  @override
  String get day_thursday_very_short => 'T';

  @override
  String get day_friday_very_short => 'F';

  @override
  String get day_saturday_very_short => 'S';

  @override
  String get day_sunday_very_short => 'S';

  @override
  String get delete_medicine_confirm => 'この薬を削除してもよろしいですか?';

  @override
  String get i_agree_to => 'を読んで同意します';

  @override
  String get read_privacy_policy => 'プライバシーポリシー';

  @override
  String get read_terms => '利用規約';

  @override
  String get read_disclaimer => '法的免責事項';

  @override
  String get must_agree => '続行するには法的文書に同意する必要があります。';

  @override
  String get legal_acceptance => '法的承認';

  @override
  String get manage_subscription => 'サブスクリプションの管理';

  @override
  String get trust_offline_title => 'オフラインサンクチュアリ';

  @override
  String get trust_offline_desc => 'データがデバイスの外に出ることはありません。';

  @override
  String get trust_encryption_title => 'AES-256暗号化';

  @override
  String get trust_encryption_desc => '最大限のセキュリティで保護されています。';

  @override
  String get trust_adfree_desc => '途切れることのない体験。';

  @override
  String get medals_trophies => 'メダルとトロフィー';

  @override
  String get cat_streak => '毎日の連続記録';

  @override
  String get cat_ads => 'サポートと広告';

  @override
  String get cat_documents => '記録アーカイブ';

  @override
  String get cat_medications => '薬の習慣';

  @override
  String get cat_appointments => '臨床訪問';

  @override
  String get cat_profile => '身元';

  @override
  String get cat_emergency => '安全性と準備';

  @override
  String get cat_health => 'バイタルモニタリング';

  @override
  String get cat_engagement => 'アプリのアクティビティ';

  @override
  String get cat_special => '栄誉';

  @override
  String get cat_premium => 'サポーター';

  @override
  String get cat_power_user => 'レジェンドステータス';

  @override
  String get ach_legend_status => '伝説の';

  @override
  String get theme_boutique => 'テーマブティック';

  @override
  String get days_left => '残り日数';

  @override
  String get unlocked => 'ロック解除済み';

  @override
  String get progress => '進捗';

  @override
  String get ach_hidden_desc => 'この秘密の成果を発見するためにプレイを続けてください。';

  @override
  String get ach_login_1_desc => 'すべての伝説的な旅は一歩から始まります。最初の連勝記録を達成しました!';

  @override
  String get ach_login_3_title => 'ウォーミングアップ';

  @override
  String get ach_login_3_desc =>
      'ウォームアップラップが終わりました。 3日連続でここに来ましたね、全然悪くないですよ！ 🔥';

  @override
  String get ach_login_7_title => '一貫性のある';

  @override
  String get ach_login_7_desc => '丸一週間！コツを学び、キャンプファイヤーに火をつけました。';

  @override
  String get ach_login_14_title => '習慣的な';

  @override
  String get ach_login_14_desc => '2週連続！習慣はこうやって鍛えられるのです。おめでとうございます。';

  @override
  String get ach_login_30_title => '中毒';

  @override
  String get ach_login_30_desc => 'まるまる一ヶ月！私たち二人とも、これが単なる趣味ではないことを知っています。';

  @override
  String get ach_login_60_title => '忠実なユーザー';

  @override
  String get ach_login_60_desc => '2か月... 家賃払ってますか、友達？あなたの第二の家へようこそ。 🏠';

  @override
  String get ach_login_100_title => '専門家';

  @override
  String get ach_login_100_desc => '世紀！いかなる力も100日連続記録を破ることはできません。 💯';

  @override
  String get ach_login_200_title => '伝説';

  @override
  String get ach_login_200_desc => '200日。人々はあなたが AI ボットではないかと疑い始めています。 🤖';

  @override
  String get ach_login_365_title => '伝説の年';

  @override
  String get ach_login_365_desc => 'まるまる太陽年！あなたはすべてを乗り越えてここに来ました。明日は戴冠式。 👑';

  @override
  String get ach_ads_1_title => '最初の広告';

  @override
  String get ach_ads_1_desc => '広告は良いものです...時々。小さなサポートに感謝します！';

  @override
  String get ach_ads_5_title => 'サポーター';

  @override
  String get ach_ads_5_desc => 'あなたも私たちと同じようにスポンサーを愛しているようですね。';

  @override
  String get ach_ads_15_title => '忠実な視聴者';

  @override
  String get ach_ads_15_desc => 'ポップコーンを手に取って、15 広告マラソンを完走しました。 🍿';

  @override
  String get ach_ads_30_title => 'それを維持する';

  @override
  String get ach_ads_30_desc => 'テレビを見ているみたいに！あなたのサポートは金の重みに値します。';

  @override
  String get ach_ads_50_title => 'パワーユーザー';

  @override
  String get ach_ads_50_desc => 'どの広告が 2 番目に表示されるかを予測できるようになりました。';

  @override
  String get ach_ads_100_title => '中毒';

  @override
  String get ach_ads_100_desc => '広告100枚！あなたの忍耐に対して、私たちはあなたに特別なメダルを授ける義務があります。';

  @override
  String get ach_ads_250_title => 'アドマスター';

  @override
  String get ach_ads_250_desc => 'マーケティングの天才がスクリーンに消えた。皆様のご支援は空まで届きました。';

  @override
  String get ach_ads_500_title => 'マネタイズキング';

  @override
  String get ach_ads_500_desc => 'あなたは金融業者ですか？あなたは単独で市場を運営しています。 📉';

  @override
  String get ach_doc_1_title => '最初の文書';

  @override
  String get ach_doc_1_desc => '役所ではありませんが、初めての書類提出に成功しました。 📇';

  @override
  String get ach_doc_5_title => '始まり';

  @override
  String get ach_doc_5_desc => '最初のフォルダーがほぼいっぱいです。整理整頓が進んでいます。';

  @override
  String get ach_doc_10_title => '一般ユーザー';

  @override
  String get ach_doc_10_desc =>
      'ファイルが溜まっていきます。 Lost and Found はあなたと協力したいと思っています。';

  @override
  String get ach_doc_25_title => 'アーキビスト';

  @override
  String get ach_doc_25_desc => '書類手続きもすべて... アーカイブ内の 25 件の文書を調べました。';

  @override
  String get ach_doc_50_title => 'プロ';

  @override
  String get ach_doc_50_desc => '秘書の仕事は忘れてください。これがプロのファイリングナイトの姿です。';

  @override
  String get ach_doc_100_title => 'ボールトマスター';

  @override
  String get ach_doc_100_desc => '書類100枚？この大規模なアーカイブの司書を任命する時期が来ました。 📚';

  @override
  String get ach_doc_250_title => 'データコレクター';

  @override
  String get ach_doc_250_desc => 'ビッグデータ シナリオへようこそ。あなたはスタックを支配します。';

  @override
  String get ach_doc_500_title => 'デジタルアーカイブの専門家';

  @override
  String get ach_doc_500_desc => 'アレクサンドリアのデジタル図書館！あなたのアーカイブは何世代にもわたって残ります。';

  @override
  String get ach_med_1_title => 'ファーストメッド';

  @override
  String get ach_med_1_desc => 'あなたは自分自身を大切にし始めました。あなたの健康にとって素晴らしいマイルストーンです。';

  @override
  String get ach_med_3_title => '追跡を開始しました';

  @override
  String get ach_med_3_desc => 'あなたの処方箋に忠実です。水を飲んで、リマインダーを見逃すことはありません。';

  @override
  String get ach_med_5_title => '一般ユーザー';

  @override
  String get ach_med_5_desc => '薬剤師のお気に入りのお客様！フォームを注意深く維持しています。';

  @override
  String get ach_med_10_title => '規律正しい';

  @override
  String get ach_med_10_desc => '薬を時間通りに服用すれば、体は時計のように機能します。 10回確定！';

  @override
  String get ach_med_25_title => '健康専門家';

  @override
  String get ach_med_25_desc =>
      'あなたは自分の体の言語を理解しています。 Med log はあなたにとって芸術になりました。';

  @override
  String get ach_med_50_title => 'ヘルスマスター';

  @override
  String get ach_med_50_desc => '医者もあなたの規律を羨ましく思っています。あなたはあなたの体の化学の達人です！ 🧬';

  @override
  String get ach_app_1_title => '最初の診察';

  @override
  String get ach_app_1_desc => '自然に計画を立てなければ成功はありません。初めてのカレンダーエントリーが無事に完了しました。';

  @override
  String get ach_app_3_title => '企画';

  @override
  String get ach_app_3_desc => '時間管理 101. 自分の計画に忠実であり続けることで上昇します。';

  @override
  String get ach_app_5_title => '整頓された';

  @override
  String get ach_app_5_desc =>
      'あなたの予定はいっぱいになってきています。多忙だけどカリスマ性のあるあの人は、きっとあなたです。';

  @override
  String get ach_app_10_title => '規律あるプランナー';

  @override
  String get ach_app_10_desc => 'アラームは必要ありません。頭の中に原子時計があります。';

  @override
  String get ach_app_20_title => 'プランナープロ';

  @override
  String get ach_app_20_desc => 'すべてが分まで明確です...あなたはデジタルアシスタントのようなものです!';

  @override
  String get ach_app_30_title => 'マスタープランナー';

  @override
  String get ach_app_30_desc =>
      'タイムベンダー！これらのアプリケーションを 1 人で管理するのは不可能に思えます...しかし、そうではありませんでした。';

  @override
  String get ach_profile_created_title => 'プロファイルが作成されました';

  @override
  String get ach_profile_created_desc => '正式に加入しました。すでにデジタルマークを作成しています。';

  @override
  String get ach_profile_completed_title => 'プロファイルが完了しました';

  @override
  String get ach_profile_completed_desc =>
      'ギャップを見逃すのは嫌いですよね？すべての情報が完璧に詰まっています。';

  @override
  String get ach_profile_updated_title => 'プロフィールが更新されました';

  @override
  String get ach_profile_updated_desc => '変化は進歩です！リフレッシュして試合に残りましたね。';

  @override
  String get ach_profile_with_photo_title => 'プロフィール写真';

  @override
  String get ach_profile_with_photo_desc => '顔のないアバターから救われました。カメラに向かって笑顔で！ 📸';

  @override
  String get ach_profile_master_title => 'プロファイルマスター';

  @override
  String get ach_profile_master_desc =>
      'あなたの ID と経歴により、あなたはシステム内で最も洗練されたユーザーになります。';

  @override
  String get ach_emergency_added_title => '緊急カードを追加しました';

  @override
  String get ach_emergency_added_desc => '予防策が取り残されることはありません。緊急シールドが作動しています。';

  @override
  String get ach_emergency_contact_title => '緊急連絡先';

  @override
  String get ach_emergency_contact_desc =>
      '困難なときに誰に電話すればよいかは明らかです。信頼の輪が生まれました。 📞';

  @override
  String get ach_emergency_complete_title => '完了';

  @override
  String get ach_emergency_complete_desc => 'シナリオの準備ができました。セキュリティレベルは最高。';

  @override
  String get ach_emergency_ready_title => '準備ができて';

  @override
  String get ach_emergency_ready_desc => 'すべてが緊急警報の時計のように機能します。安全に確保されています。';

  @override
  String get ach_emergency_master_title => 'エマージェンシーマスター';

  @override
  String get ach_emergency_master_desc => '救急車が到着する前に応急処置を行えるほどタフでクールです。';

  @override
  String get ach_health_1_title => '最初のデータ';

  @override
  String get ach_health_1_desc => '今日はあなたが自分に良いことをしてくれました。あなたの体は内側からあなたに感謝します。';

  @override
  String get ach_health_5_title => '追跡を開始しました';

  @override
  String get ach_health_5_desc => 'データが蓄積され、バイオリズムとの会話が進んでいます。';

  @override
  String get ach_health_10_title => '健康志向';

  @override
  String get ach_health_10_desc => 'あなたは統計上の驚異です!あなたの体は暗号化された本のように読み取れます。 📈';

  @override
  String get ach_health_20_title => '定期的な追跡';

  @override
  String get ach_health_20_desc =>
      'あなたは機械のようなものです。脈拍、指標、歩数...どれもセンサーから逃れることはできません。';

  @override
  String get ach_health_50_title => '健康専門家';

  @override
  String get ach_health_50_desc =>
      'サイボーグレベルに近づいている。あなたとあなたのバイオデータとの間の絆は切れることがありません。';

  @override
  String get ach_health_master_title => 'ヘルスマスター';

  @override
  String get ach_health_master_desc =>
      '神殿の大神官よ！あなたは自分自身の体に対する絶対的な支配を確立しました。 🧘';

  @override
  String get ach_first_login_title => 'いらっしゃいませ';

  @override
  String get ach_first_login_desc =>
      '本当の冒険はまだ始まったばかりです。あなたはちょうど中に足を踏み入れたところです。';

  @override
  String get ach_first_upload_title => 'エクスプローラ';

  @override
  String get ach_first_upload_desc => '初めて永久的な足跡を残しました。あなたは今ここに刻まれています。';

  @override
  String get ach_first_ad_title => '無料ユーザー';

  @override
  String get ach_first_ad_desc => '初めての広告インタラクション!あなたは生態系に活力を与えました。';

  @override
  String get ach_first_premium_title => 'プレミアムユーザー';

  @override
  String get ach_first_premium_desc =>
      'ビジョンの問題。レッドカーペットが敷かれ、VIP ラウンジをお楽しみください。 🎟️';

  @override
  String get ach_active_3_days_title => 'アクティブ';

  @override
  String get ach_active_3_days_desc =>
      'ケーブルが暖まり、エンジンが始動しました。私たちはあなたのエネルギーを感じます。';

  @override
  String get ach_active_7_days_title => '忠実な';

  @override
  String get ach_active_7_days_desc => '丸 1 週間システムと同期されます。物事が電気的になりました！';

  @override
  String get ach_active_30_days_title => 'コアユーザー';

  @override
  String get ach_active_30_days_desc => '今では実質名誉職員。あなたなしではこの場所は同じではありません。';

  @override
  String get ach_streak_saved_title => 'ストリークセイバー';

  @override
  String get ach_streak_saved_desc => '端から戻ってきた！その美しい筋を保存したのは素晴らしい反射神経でした。';

  @override
  String get ach_streak_saved_5_title => '弾力性のある';

  @override
  String get ach_streak_saved_5_desc =>
      '戦いの傷跡にもかかわらず転ぶことはなく、つまずいたときに立ち上がる方法を知っています。';

  @override
  String get ach_streak_saved_10_title => '決してあきらめない';

  @override
  String get ach_streak_saved_10_desc =>
      'あなたはフェニックスですか？灰から立ち上がることは、あなたにとって典型的な火曜日の活動にすぎません。 🐦🔥';

  @override
  String get ach_streak_perfect_30_title => 'パーフェクトストリーク';

  @override
  String get ach_streak_perfect_30_desc =>
      'ミスは一つもありません。あなたはスイスの時計のように、丸 30 日間完璧でした。';

  @override
  String get ach_premium_trial_used_title => 'プレミアムな体験';

  @override
  String get ach_premium_trial_used_desc => '特権への扉を開きました。この景色はとても魅力的ですよね。';

  @override
  String get ach_limit_breaker_title => 'リミットブレイカー';

  @override
  String get ach_limit_breaker_desc =>
      'ルールと制限は曲げられるためにある。マトリックスから抜け出してしまいました！ 💥';

  @override
  String get ach_ad_skip_used_title => '広告スキップ';

  @override
  String get ach_ad_skip_used_desc => 'ワンクリックで時間を早送りする時間がないって言ってたよね。';

  @override
  String get ach_reward_collector_title => '報酬コレクター';

  @override
  String get ach_reward_collector_desc => '隅にあるすべての報酬をあさりました。まさに戦利品ハンター！ 🎁';

  @override
  String get ach_multi_feature_user_title => '多機能ユーザー';

  @override
  String get ach_multi_feature_user_desc => 'ボタンひとつも触っていない、好奇心旺盛な探検家!';

  @override
  String get ach_data_master_title => 'データマスター';

  @override
  String get ach_data_master_desc => 'バイトやビットがあなたの周りで形を作ります。システムデータの絶対的なマスター。';

  @override
  String get ach_organized_master_title => '超組織的';

  @override
  String get ach_organized_master_desc =>
      '近藤麻理恵ならあなたの注文に脱帽するでしょう。すべてはミリメートルです。';

  @override
  String get ach_security_master_title => 'セキュリティ専門家';

  @override
  String get ach_security_master_desc =>
      'あなたのアカウントは要塞であり、パスワードはサイバー軍です。侵入は不可能です！ 🔐';

  @override
  String get ach_daily_master_title => 'デイリーマスター';

  @override
  String get ach_daily_master_desc => '毎日私たちと一緒に太陽や星を見ている伝説の愛用者。';

  @override
  String get backup_restore => 'バックアップと復元';

  @override
  String get backup_desc_settings => 'このデバイスのみの暗号化されたローカル バックアップ';

  @override
  String get smart_notifications => 'スマート通知';

  @override
  String get smart_streak_warning => '🔥 連勝記録がもうすぐ失われます!データを確認してみませんか?';

  @override
  String get smart_ad_reward => '🎁 広告を 1 回視聴 → +5 制限!今日はあなたにとって新たなチャンスです。';

  @override
  String get smart_doc_bonus => '📂 今日ドキュメントを 1 件追加 → ボーナスを獲得!すべてを安全に保管してください。';

  @override
  String get smart_default => '👀 小さなアップデートがあなたを待っています。今日は何ができるでしょうか?';

  @override
  String get notif_bonus_ready => '🎁 ボーナスがあなたを待っています!ご協力いただきありがとうございます。';

  @override
  String get notif_doc_safe => '🔥 よくやった、書類は無事だ!続けて！';

  @override
  String level_up_desc(int level) {
    return 'レベル$levelに到達しました!新しい報酬についてはシーズンパスを確認してください。';
  }

  @override
  String get notifications_active_msg => '通知がアクティブになっています 🔔';

  @override
  String get show_sensitive_details => '通知に詳細を表示';

  @override
  String get sensitive_details_visible => '薬名が見える';

  @override
  String get sensitive_details_hidden => '非表示 (推奨)';

  @override
  String get quiet_hours => '静かな時間';

  @override
  String get quiet_hours_msg => '今夜は邪魔しません🌙';

  @override
  String get test_notification => 'テスト通知';

  @override
  String get test_notification_desc => 'すぐにシステムをテストしてください';

  @override
  String get test_notification_body => 'テストのお知らせです';

  @override
  String get app_lock_unavailable => 'このデバイスではアプリ ロックを使用できません。';

  @override
  String get backup_restore_desc =>
      'データを暗号化してバックアップまたは復元できます。バックアップはデバイスにのみ保存されます。';

  @override
  String get backup_export => 'バックアップのエクスポート';

  @override
  String get backup_export_desc => '暗号化されたZIPバックアップを作成する';

  @override
  String get backup_import => 'インポートバックアップ';

  @override
  String get backup_import_desc => '既存の ZIP バックアップから復元する';

  @override
  String get warning => '警告';

  @override
  String get import_warning_desc =>
      'バックアップを復元すると現在のデータが削除され、元に戻すことはできません。続けますか?';

  @override
  String get yes_restore => 'はい、復元します';

  @override
  String get start_time => '開始時間';

  @override
  String get end_time => '終了時間';

  @override
  String get email => '電子メール';

  @override
  String get phone => '電話';

  @override
  String get add_record_success => 'レコードは正常に保存されました。';

  @override
  String get delete_confirm => 'このレコードを削除してもよろしいですか?';

  @override
  String get plus_5_slots => '+5 スロットを獲得しました! 🚀';

  @override
  String get watch_to_unlock => 'ロックを解除するには視聴してください';

  @override
  String remaining_days(int days) {
    return '残り: $days 日';
  }

  @override
  String get add_1_day_success => '+1日追加！ 🎉';

  @override
  String get plus_1_day => '+1日';

  @override
  String get watch => '時計';

  @override
  String get unlock_theme_question => 'このテーマを 5 日間無料で使用しませんか?';

  @override
  String get watch_ad_plus_5 => '広告を見る (+5 日)';

  @override
  String get preview_5s => 'プレビュー (5 秒)';

  @override
  String get free_secure_release => '無料の安全なリリース';

  @override
  String get encrypted_local_desc =>
      '暗号化されたドキュメントはこのデバイス上でローカルに残ります。広告は無料版をサポートしています。';

  @override
  String get premium_soon => 'プレミアムもうすぐ';

  @override
  String get label_title => 'タイトル';

  @override
  String get label_location => '場所/機関 (オプション)';

  @override
  String get label_person => '関係者 (任意)';

  @override
  String get label_date_time => '日付と時刻';

  @override
  String get label_importance => '重要性';

  @override
  String get label_reminder => 'リマインダー';

  @override
  String get label_repeat => '繰り返す';

  @override
  String get label_notes => '注記 (オプション)';

  @override
  String get hint_title => '例えば医師の予約、会議...';

  @override
  String get hint_location => 'オフィス、自宅、オンライン、病院...';

  @override
  String get hint_person => '名前、医師、弁護士…';

  @override
  String get hint_notes => '詳細、注意事項...';

  @override
  String get suggest_doctor => '医者';

  @override
  String get suggest_meeting => 'ミーティング';

  @override
  String get suggest_personal => '個人的';

  @override
  String get importance_low => '普通';

  @override
  String get importance_medium => '重要';

  @override
  String get importance_high => '致命的';

  @override
  String get reminder_10m => '10分前';

  @override
  String get reminder_1h => '1時間前';

  @override
  String get reminder_1d => '1日前';

  @override
  String get repeat_none => 'なし';

  @override
  String get repeat_daily => '毎日';

  @override
  String get repeat_weekly => '毎週';

  @override
  String get label_date_added => '追加日';

  @override
  String get label_document_date => '文書の日付';

  @override
  String get download_to_device => 'デバイスにダウンロード';

  @override
  String get delete_permanently => '完全に削除';

  @override
  String get save_document => '文書の保存';

  @override
  String get success_doc_saved => 'ドキュメントは正常に保存されました。';

  @override
  String error_failed_download(String error) {
    return 'ダウンロードに失敗しました: $error';
  }

  @override
  String get btn_add => '追加';

  @override
  String get docs_tag_lab => 'ラボの結果';

  @override
  String get docs_tag_radiology => '放射線科';

  @override
  String get docs_tag_prescription => '処方箋';

  @override
  String get docs_tag_report => 'ドクターレポート';

  @override
  String get docs_tag_operation => '手術';

  @override
  String get docs_tag_vaccination => '予防接種';

  @override
  String get docs_tag_other => '他の';

  @override
  String get season_pass => 'シーズンパス';

  @override
  String level_label(int level) {
    return 'レベル$level';
  }

  @override
  String get premium_reward => 'プレミアム報酬';

  @override
  String get free_reward => '無料報酬';

  @override
  String get claim => '請求';

  @override
  String reward_doc_slots(int value) {
    return '+$value ドキュメント';
  }

  @override
  String get premium_unavailable_title => 'このリリースではプレミアムは利用できません。';

  @override
  String get premium_unavailable_desc =>
      'VitaCase は現在、ローカル暗号化ストレージ、広告、オプションのリマインダーを備えた無料アプリとして出荷されています。';

  @override
  String get btn_close => '近い';

  @override
  String get accept => '受け入れる';

  @override
  String get btn_save => '保存';

  @override
  String get doctor_title_dr => '博士。';

  @override
  String get doctor_title_uzm => '仕様博士。';

  @override
  String get doctor_title_op => 'Op.博士。';

  @override
  String get doctor_title_prof => '教授、博士。';

  @override
  String get doctor_title_doc => '准教授教授';

  @override
  String get hint_doctor_name => 'ジョン・ドゥ博士';

  @override
  String get hint_specialty => '心臓病学';

  @override
  String get hint_hospital => '市立病院';

  @override
  String get hint_phone => '+1 (555) 000-0000';

  @override
  String get hint_email => 'john.doe@hospital.com';

  @override
  String get hint_address => 'メインストリートNo:12...';

  @override
  String get hint_personal_notes => '医師についてのメモ...';

  @override
  String get ad_reward_not_earned => '報酬は獲得できませんでした。続行するには広告を終了してください。';

  @override
  String get ad_unavailable => '広告は利用できません。';

  @override
  String get ad_failed => 'リワード広告を表示できませんでした。もう一度試してください。';

  @override
  String get ad_watch_btn => '無料で続ける (広告を見る)';

  @override
  String get btn_not_now => '今じゃない';

  @override
  String get theme_system => 'システム';

  @override
  String get theme_light => 'ライト';

  @override
  String get theme_dark => '暗い';

  @override
  String get lock_timeout_1m => '1分';

  @override
  String get lock_timeout_5m => '5分';

  @override
  String get lock_timeout_15m => '15分';

  @override
  String get error_title_required => 'タイトルは必須です';

  @override
  String get notif_app_created_title => '🎯 予約が作成されました';

  @override
  String notif_app_created_body(String title) {
    return '$title がスケジュールされました。';
  }

  @override
  String get notif_app_reminder_title => '📅 予約リマインダー';

  @override
  String notif_app_reminder_body(String title) {
    return '$title の予約が近づいています。';
  }

  @override
  String get no_appointments_found => '予定が見つかりませんでした';

  @override
  String get empty_appointments_desc => 'まだ予定を追加していません。 + ボタンをタップして追加します。';

  @override
  String get empty_appointments_filter_desc => 'このカテゴリでは予定が見つかりません。';

  @override
  String get btn_add_appointment => '予約を追加';

  @override
  String get btn_clear_filters => 'クリアフィルター';

  @override
  String get delete_confirm_appointment => 'この予定を削除してもよろしいですか?';

  @override
  String get create_today_plan => '今日の計画を作成する';

  @override
  String get plan_time_desc => '健康スケジュールを簡単に管理できます。';

  @override
  String get docs_add_short => '追加';

  @override
  String get docs_open => '開ける';

  @override
  String get docs_download => 'デバイスにダウンロード';

  @override
  String get docs_delete_perm => '完全に削除';

  @override
  String get docs_date_added => '追加日';

  @override
  String get docs_document_date => '文書の日付';

  @override
  String get docs_save_success => 'ドキュメントは正常に保存されました。';

  @override
  String docs_download_failed(String error) {
    return 'ダウンロードに失敗しました: $error';
  }

  @override
  String get season_pass_title => 'シーズンパス';

  @override
  String season_level(int level) {
    return 'レベル$level';
  }

  @override
  String get claim_reward => '請求';

  @override
  String get confirm_agree => '同意します';

  @override
  String get specialty_department_hint => '例えば心臓病学';

  @override
  String get hospital_hint => '例えば市立病院';

  @override
  String get address_hint => '通り、いいえ、建物...';

  @override
  String get notes_hint => '医師についての個人的なメモ...';

  @override
  String get standard_modes => '標準モード';

  @override
  String get premium_palettes => 'プレミアムパレット';

  @override
  String get apply_theme => 'テーマの適用';

  @override
  String get theme_luxe_sanctuary => 'リュクス サンクチュアリ';

  @override
  String get theme_midnight_neon => 'ミッドナイトネオン';

  @override
  String get theme_amethyst_aura => 'アメジストのオーラ';

  @override
  String get theme_emerald_garden => 'エメラルド ガーデン';

  @override
  String get theme_ocean_serenity => 'オーシャン セレニティ';

  @override
  String get theme_amber_glow => 'アンバーグロー';

  @override
  String get db_recovery_title => 'データエラー';

  @override
  String get db_recovery_desc => 'データにアクセスできませんでした。もう一度試してみますか?';

  @override
  String get db_recovery_retry => 'もう一度やり直してください';

  @override
  String get db_recovery_reset => 'リセット';

  @override
  String get notif_streak_warning_title => '一日の計画を確認する';

  @override
  String get notif_streak_warning_body =>
      'VitaCase を開いて、今日のリマインダーと保存したアイテムを確認します。';

  @override
  String get notif_mission_reminder_title => '🎯 デイリーミッションは保留中です';

  @override
  String get notif_mission_reminder_body => '毎日の報酬をお見逃しなく！今すぐタスクを完了してください。';

  @override
  String get notif_limit_reached_title => '🚀 制限に達しました';

  @override
  String get notif_limit_reached_body => '無料制限に達しました。続行するにはリワード広告を視聴してください。';

  @override
  String get notif_good_morning_title => '🌞おはようございます！';

  @override
  String get notif_good_morning_body => 'VitaCase で 1 日をスタートし、毎日のタスクを確認してください。';

  @override
  String get notif_test_title => 'テスト通知';

  @override
  String get notif_test_body => '通知は完璧に機能しています。';

  @override
  String get notif_appointment_reminder_title => '📅 予約リマインダー';

  @override
  String notif_appointment_reminder_body(String doctor) {
    return '$doctor の予約が近づいています。';
  }

  @override
  String get get_directions => '道順を調べる';

  @override
  String get view_details => '詳細を見る';

  @override
  String get no_scheduled_meds_today => '今日は投薬予定はありません。';

  @override
  String get add_appointment => '予定を追加';

  @override
  String get add_document => 'ドキュメントの追加';

  @override
  String get ach_login_1_title => '始まり';

  @override
  String get people_contacts => '人物と連絡先';

  @override
  String get contacts_subtitle => '人、機関、および連絡先の記録';

  @override
  String get add_contact_subtitle => '新しい人または機関を追加する';

  @override
  String get add_contact => '人物/連絡先を追加';

  @override
  String get no_doctor => '医者がいない';

  @override
  String get no_institution => '機関なし';

  @override
  String get edit_personal_info => '個人情報の編集';

  @override
  String get personal_info_updated => '個人情報を更新しました。';

  @override
  String get edit_important_info => '重要な情報を編集する';

  @override
  String get hint_allergies => 'カンマで区切る: 花粉、ペニシリン';

  @override
  String get hint_medications => 'カンマで区切る: アスピリン、ビタミン D';

  @override
  String get relationship => '関係';

  @override
  String get hint_relationship => '配偶者、母親、父親、兄弟...';

  @override
  String get important_info_updated => '重要な情報が更新されました。';

  @override
  String get reminder_troubleshooting => 'リマインダーのトラブルシューティング';

  @override
  String get reminder_troubleshooting_desc => '通知、正確なアラーム、バッテリー設定を確認する';

  @override
  String get status_checking => 'チェック中...';

  @override
  String get status_enabled => '通知許可が有効になっています';

  @override
  String get status_disabled => '通知許可が無効になっています';

  @override
  String get why_no_reminders => 'リマインダーが届かない場合がある理由';

  @override
  String get why_no_reminders_desc =>
      '通知許可、正確なアラーム許可、またはデバイスのバッテリー管理により、予約や薬のリマインダーがブロックされる場合があります。最初に権限を確認してください。バッテリーの最適化は、テストが失敗した場合の最後のステップとしてのみ検討してください。';

  @override
  String get status_card_title => '通知ステータス';

  @override
  String get check_notif_permission => '1. 通知許可を確認する';

  @override
  String get check_notif_permission_desc =>
      'インスタント通知が無効になっている場合、リマインダーは表示されません。';

  @override
  String get req_notif_permission => '通知許可のリクエスト';

  @override
  String get check_exact_alarm => '2.正確なアラーム許可を確認する';

  @override
  String get check_exact_alarm_desc => '予約や薬のリマインダーを時間どおりに実行するために必要です。';

  @override
  String get req_exact_alarm => '正確なアラーム許可を要求する';

  @override
  String get resched_saved => '3. 保存したリマインダーのスケジュールを変更する';

  @override
  String get resched_saved_desc => '権限を付与した後、保存した薬と予約のリマインダーを再度スケジュールします。';

  @override
  String get resched_btn => 'リマインダーのスケジュールを変更する';

  @override
  String get sched_test => '4. 1 分間のテストリマインダーをスケジュールする';

  @override
  String get sched_test_desc => 'これが到着した場合は、リマインダーシステムが機能しています。';

  @override
  String get sched_test_btn => '1 分間のテストをスケジュールする';

  @override
  String get last_step_battery => '5. 最後のステップ: バッテリー設定を確認する';

  @override
  String get last_step_battery_desc =>
      '上記のテストが失敗した場合にのみ、デバイスが VitaCase のバッテリー使用を制限しているかどうかを確認してください。';

  @override
  String get open_app_settings => 'アプリ設定を開く';

  @override
  String get snack_notif_checked => '通知許可がチェックされました。';

  @override
  String get snack_exact_alarm_requested =>
      '正確なアラーム許可が要求されました。デバイスの設定で許可する必要がある場合があります。';

  @override
  String get test_notif_title => '⏰ VitaCase リマインダーテスト';

  @override
  String get test_notif_body => 'このテスト リマインダーは 1 分後にスケジュールされていました。';

  @override
  String get snack_test_sched => 'テストのリマインダーは 1 分後にスケジュールされます。';

  @override
  String get snack_resched_completed => '保存された薬と予約のリマインダーが再スケジュールされました。';

  @override
  String get choose_pdf_or_image => 'PDFまたは画像を選択してください';

  @override
  String get encrypted_local_file_info => 'ファイルは暗号化され、このデバイスにローカルに保存されます。';

  @override
  String get web_upload_info => 'ファイルボルトのアップロードは、Android/iOS ビルドで利用できます。';

  @override
  String get web_preview_no_upload =>
      'Web プレビューでは、暗号化されたファイルは保存されません。ボールトのアップロードには Android/iOS を使用します。';

  @override
  String get choose_file_first => '最初に PDF または画像を選択してください。';

  @override
  String get document_saved => 'ドキュメントは安全に保存されました。';

  @override
  String save_document_failed(String error) {
    return 'ドキュメントを保存できませんでした: $error';
  }

  @override
  String get save_securely => '安全に保存する';

  @override
  String get saving => '保存中...';

  @override
  String get local_organizer_disclaimer =>
      'VitaCase はローカルのドキュメント オーガナイザーです。診断、分析、または医学的アドバイスを提供するものではありません。';

  @override
  String get terms_and_legal_agreement => '私はプライバシー ポリシー、利用規約、および法的免責事項に同意します。';

  @override
  String get free_themes => '無料のテーマ';

  @override
  String get reward_themes => '報酬テーマ';

  @override
  String get reward_themes_info =>
      'リワード広告を 1 つ視聴すると、3 日間これらのテーマのロックを解除できます。広告を追加するごとに +1 日追加されます。';

  @override
  String get watch_ad_to_unlock => '広告を見てロックを解除する';

  @override
  String get tap_to_preview => 'タップしてプレビューします';

  @override
  String get add_one_day => '+1日追加';

  @override
  String get one_day_added => '+1日追加されました。';

  @override
  String get ad_unavailable_try_later => '広告は利用できません。後でもう一度試してください。';

  @override
  String get theme_unlocked => 'テーマのロックが解除されました。追加の広告ごとに +1 日追加されます。';

  @override
  String reward_themes_active(String days) {
    return '$days 日間有効な報酬テーマ。';
  }

  @override
  String get lock_use_pin => 'PINを使用する';

  @override
  String get pending => '保留中';

  @override
  String get document_details_subtitle => '拡張されたドキュメントの詳細を確認します。';

  @override
  String get document_name => '文書名';

  @override
  String get document_name_hint => '例えば血液検査の結果';

  @override
  String daily_limit_reached_message(int limit) {
    return '今日の作成制限 ($limit) に達しました。明日はさらに追加できます。';
  }

  @override
  String get document_updated => 'ドキュメントが更新されました。';

  @override
  String get document_update_failed => 'ドキュメントを更新できませんでした。';

  @override
  String get document_open_failed => 'ドキュメントを開けませんでした。';

  @override
  String get no_additional_notes => '追加のメモは提供されません。';

  @override
  String get created_at_label => '作成日';

  @override
  String get physician_label => '医師';

  @override
  String get open => '開ける';

  @override
  String get document_vault => '文書保管庫';

  @override
  String get document_vault_view_subtitle => '拡張されたドキュメントの詳細を確認します。';

  @override
  String get institution_hospital => '施設・病院';

  @override
  String get doctor_related_person => '医師・関係者';

  @override
  String get add_contact_title => '人物/連絡先を追加';

  @override
  String get contact_info_title => '人物/連絡先情報';

  @override
  String get contact_info_desc => '重要な人物、機関、連絡先の詳細を保存して、すぐにアクセスできるようにします。';

  @override
  String get person_contact_label => '人物・連絡先';

  @override
  String get category_area_label => 'カテゴリー・エリア';

  @override
  String get institution_source_label => '機関/情報源';

  @override
  String get person_hint => '例えばスミス博士、アドバイザー、クリニック担当者';

  @override
  String get category_hint => '例えば健康診断、歯科、治療、相談';

  @override
  String get institution_hint => '例えばクリニック、研究室、オフィス、オンライン ソース';

  @override
  String get required_contact_error => '担当者/連絡先、カテゴリ/地域情報を入力してください。';

  @override
  String get contacts_title => '人物/連絡先';

  @override
  String get contacts_search_hint => '人物、機関、カテゴリーを検索する';

  @override
  String get no_contacts_found => '一致する連絡先が見つかりませんでした';

  @override
  String get contact_detail_title => '人物/連絡先詳細';

  @override
  String get institution_source => '機関/情報源';

  @override
  String get category_area => 'カテゴリー・エリア';

  @override
  String get sub_area => 'サブエリア';

  @override
  String get privacy_policy_short => 'プライバシーポリシー';

  @override
  String get terms_short => '条項';

  @override
  String get disclaimer_short => '免責事項';

  @override
  String debug_panel_taps_left(String remaining) {
    return 'デバッグパネル: $remaining を左にタップします。';
  }

  @override
  String get delete_confirm_dialog_title => '文書を削除しますか?';

  @override
  String get delete_confirm_dialog_desc =>
      'この文書は保管庫から削除されます。この操作は元に戻すことができません。';

  @override
  String get document_deleted_msg => '文書が削除されました。';

  @override
  String get sort_newest_first => '新しい順';

  @override
  String get sort_oldest_first => '古い順';

  @override
  String get sort_a_z => 'A-Z';

  @override
  String get sort_label => '選別';

  @override
  String get medication_reminder_past_note =>
      '選択した時間がすでに今日を過ぎている場合、最初のリマインダーは次の適切な時間にスケジュールされます。';

  @override
  String get appointment_reminder_past_note =>
      '選択したリマインダー時刻がすでに過去の場合、VitaCase は最も近い適切な時刻を選択します。';

  @override
  String get limit_unlock_token_title => 'リミットアンロックトークン';

  @override
  String get limit_unlock_status_active => 'アクティブ';

  @override
  String limit_unlock_status_coming_soon(String version) {
    return '$version が到着します';
  }

  @override
  String limit_unlock_desc_active(String xp) {
    return '$xp XP ごとに 1 つの制限解除トークンが付与されます。 1 日あたりの制限に達すると、自動的に使用されます。';
  }

  @override
  String limit_unlock_desc_inactive(String version, String xp) {
    return 'V1 では無効になっています。 $version では、$xp XP ごとに 1 つの制限解除トークンが付与されます。';
  }

  @override
  String get limit_unlock_stat_total_xp => '合計XP';

  @override
  String get limit_unlock_stat_xp_left => 'XPが残っています';

  @override
  String get limit_unlock_stat_tokens => 'トークン';

  @override
  String get notes => '注意事項';

  @override
  String get privacy_guaranteed_title => 'Privacy Guaranteed';

  @override
  String get privacy_guaranteed_desc =>
      'Your health data is encrypted and stored only on your device.';

  @override
  String get pin_not_set => 'PIN Not Set';

  @override
  String get pin_not_set_desc => 'Enable app lock (PIN) to secure your data.';

  @override
  String get create_btn => 'Create';

  @override
  String get enter_6_digit_pin => 'Please enter a 6-digit PIN.';

  @override
  String pin_save_failed(String error) {
    return 'Failed to save PIN: $error';
  }

  @override
  String get create_new_pin => 'Create New PIN';

  @override
  String get confirm_pin_label => 'Confirm your PIN';

  @override
  String get enter_6_digit_pin_label => 'Enter 6-digit PIN';

  @override
  String get theme_forest_sanctuary => 'Forest Sanctuary';

  @override
  String get splashTagline => 'Your health, safely organized.';

  @override
  String get daily_reminders => 'Daily Reminders';

  @override
  String get daily_reminders_desc =>
      'Receive a daily notification to review your plans, discover themes, and organize your vault.';
}
