require 'test_helper'

class HtmlTextHelperTest < ActionView::TestCase
  include HtmlTextHelper

  test 'should wrap correctly at max 80 chars' do
    content = wrap_and_quote('lorem ipsum dolor sit amet' * 10)
    content.split("\n").each do |line|
      assert_operator line.length, :<=, 80 - "\n".length
    end
  end

  test 'should remove older quotes correctly' do

    content = '
hi, thanks for you reply

On date, person wrote:
> older quote
>> older quote
> > older quote
'

    stripped = wrap_and_quote(content)

    refute_match(/On date, person wrote/, stripped)
    refute_match(/older quote/, stripped)
  end

  test 'should remove html comments correctly' do
    content = '<!-- /* Font Definitions */ @font-face {font-family:"Cambria Math";
        panose-1:2 4 5 3 5 4 6 3 2 4;} @font-face {font-family:Calibri; panose-1:2
        15 5 2 2 2 4 3 2 4;} @font-face {font-family:Consolas; panose-1:2 11 6 9 2 2
        4 3 2 4;} /* Style Definitions */ p.MsoNormal, li.MsoNormal, div.MsoNormal
        {margin:0cm; margin-bottom:.0001pt; font-size:12.0pt; font-family:"Times New
        Roman",serif;} a:link, span.MsoHyperlink {mso-style-priority:99; color:blue;
        text-decoration:underline;} a:visited, span.MsoHyperlinkFollowed
        {mso-style-priority:99; color:purple; text-decoration:underline;} p
        {mso-style-priority:99; mso-margin-top-alt:auto; margin-right:0cm;
        mso-margin-bottom-alt:auto; margin-left:0cm; font-size:12.0pt;
        font-family:"Times New Roman",serif;} pre {mso-style-priority:99;
        mso-style-link:"HTML Preformatted Char"; margin:0cm; margin-bottom:.0001pt;
        font-size:10.0pt; font-family:"Courier New";} p.msonormal0, li.msonormal0,
        div.msonormal0 {mso-style-name:msonormal; mso-margin-top-alt:auto;
        margin-right:0cm; mso-margin-bottom-alt:auto; margin-left:0cm;
        font-size:12.0pt; font-family:"Times New Roman",serif;}
        span.HTMLPreformattedChar {mso-style-name:"HTML Preformatted Char";
        mso-style-priority:99; mso-style-link:"HTML Preformatted";
        font-family:Consolas; mso-fareast-language:EN-GB;} span.EmailStyle21
        {mso-style-type:personal-reply; font-family:"Calibri",sans-serif;
        color:windowtext;} .MsoChpDefault {mso-style-type:export-only;
        font-family:"Calibri",sans-serif; mso-fareast-language:EN-US;} @page
        WordSection1 {size:612.0pt 792.0pt; margin:72.0pt 72.0pt 72.0pt 72.0pt;}
        div.WordSection1 {page:WordSection1;} -->Hello'
    stripped = strip_inline_style(content)
    assert_equal 'Hello', stripped
  end

  test 'should replace cid: src with actual urls' do
    content = '<img src="cid:CONTENT_ID" />'
    assert_match(/<img src="TEST".*>/,
        sanitize_html(content, { 'CONTENT_ID' => 'TEST' }))
  end
end
