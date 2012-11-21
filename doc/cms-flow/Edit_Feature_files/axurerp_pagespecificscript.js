
var PageName = 'Edit Feature';
var PageId = '781467abf6ac446e854cdc2a55818033'
var PageUrl = 'Edit_Feature.html'
document.title = 'Edit Feature';
var PageNotes = 
{
"pageName":"Edit Feature",
"showNotesNames":"False"}
var $OnLoadVariable = '';

var $CSUM;

var hasQuery = false;
var query = window.location.hash.substring(1);
if (query.length > 0) hasQuery = true;
var vars = query.split("&");
for (var i = 0; i < vars.length; i++) {
    var pair = vars[i].split("=");
    if (pair[0].length > 0) eval("$" + pair[0] + " = decodeURIComponent(pair[1]);");
} 

if (hasQuery && $CSUM != 1) {
alert('Prototype Warning: The variable values were too long to pass to this page.\nIf you are using IE, using Firefox will support more data.');
}

function GetQuerystring() {
    return '#OnLoadVariable=' + encodeURIComponent($OnLoadVariable) + '&CSUM=1';
}

function PopulateVariables(value) {
    var d = new Date();
  value = value.replace(/\[\[OnLoadVariable\]\]/g, $OnLoadVariable);
  value = value.replace(/\[\[PageName\]\]/g, PageName);
  value = value.replace(/\[\[GenDay\]\]/g, '13');
  value = value.replace(/\[\[GenMonth\]\]/g, '3');
  value = value.replace(/\[\[GenMonthName\]\]/g, 'March');
  value = value.replace(/\[\[GenDayOfWeek\]\]/g, 'Tuesday');
  value = value.replace(/\[\[GenYear\]\]/g, '2012');
  value = value.replace(/\[\[Day\]\]/g, d.getDate());
  value = value.replace(/\[\[Month\]\]/g, d.getMonth() + 1);
  value = value.replace(/\[\[MonthName\]\]/g, GetMonthString(d.getMonth()));
  value = value.replace(/\[\[DayOfWeek\]\]/g, GetDayString(d.getDay()));
  value = value.replace(/\[\[Year\]\]/g, d.getFullYear());
  return value;
}

function OnLoad(e) {

}

var u230 = document.getElementById('u230');

var u231 = document.getElementById('u231');
gv_vAlignTable['u231'] = 'top';
var u232 = document.getElementById('u232');

var u233 = document.getElementById('u233');
gv_vAlignTable['u233'] = 'center';
var u70 = document.getElementById('u70');

u70.style.cursor = 'pointer';
if (bIE) u70.attachEvent("onclick", Clicku70);
else u70.addEventListener("click", Clicku70, true);
function Clicku70(e)
{
windowEvent = e;


if (true) {

	self.location.href="Management_Channel.html" + GetQuerystring();

}

}

var u71 = document.getElementById('u71');

var u100 = document.getElementById('u100');
gv_vAlignTable['u100'] = 'center';
var u101 = document.getElementById('u101');

u101.style.cursor = 'pointer';
if (bIE) u101.attachEvent("onclick", Clicku101);
else u101.addEventListener("click", Clicku101, true);
function Clicku101(e)
{
windowEvent = e;


if (true) {

	self.location.href="Features.html" + GetQuerystring();

}

}

var u102 = document.getElementById('u102');

var u103 = document.getElementById('u103');
gv_vAlignTable['u103'] = 'center';
var u104 = document.getElementById('u104');

u104.style.cursor = 'pointer';
if (bIE) u104.attachEvent("onclick", Clicku104);
else u104.addEventListener("click", Clicku104, true);
function Clicku104(e)
{
windowEvent = e;


if (true) {

	self.location.href="resources/reload.html#" + encodeURI(PageUrl + GetQuerystring());

}

}

var u105 = document.getElementById('u105');

var u106 = document.getElementById('u106');
gv_vAlignTable['u106'] = 'center';
var u107 = document.getElementById('u107');

var u108 = document.getElementById('u108');

var u109 = document.getElementById('u109');
gv_vAlignTable['u109'] = 'center';
var u258 = document.getElementById('u258');
gv_vAlignTable['u258'] = 'center';
var u259 = document.getElementById('u259');

var u80 = document.getElementById('u80');

var u81 = document.getElementById('u81');
gv_vAlignTable['u81'] = 'center';
var u82 = document.getElementById('u82');

u82.style.cursor = 'pointer';
if (bIE) u82.attachEvent("onclick", Clicku82);
else u82.addEventListener("click", Clicku82, true);
function Clicku82(e)
{
windowEvent = e;


if (true) {

	self.location.href="Image_Library.html" + GetQuerystring();

}

}

var u83 = document.getElementById('u83');

var u84 = document.getElementById('u84');
gv_vAlignTable['u84'] = 'center';
var u85 = document.getElementById('u85');

var u86 = document.getElementById('u86');
gv_vAlignTable['u86'] = 'center';
var u87 = document.getElementById('u87');

u87.style.cursor = 'pointer';
if (bIE) u87.attachEvent("onclick", Clicku87);
else u87.addEventListener("click", Clicku87, true);
function Clicku87(e)
{
windowEvent = e;


if (true) {

	self.location.href="Image_Library.html" + GetQuerystring();

}

}

var u88 = document.getElementById('u88');

var u89 = document.getElementById('u89');
gv_vAlignTable['u89'] = 'center';
var u118 = document.getElementById('u118');

var u119 = document.getElementById('u119');

var u268 = document.getElementById('u268');

var u269 = document.getElementById('u269');

var u90 = document.getElementById('u90');

u90.style.cursor = 'pointer';
if (bIE) u90.attachEvent("onclick", Clicku90);
else u90.addEventListener("click", Clicku90, true);
function Clicku90(e)
{
windowEvent = e;


if (true) {

	self.location.href="Add_Image.html" + GetQuerystring();

}

}

var u91 = document.getElementById('u91');

var u92 = document.getElementById('u92');
gv_vAlignTable['u92'] = 'center';
var u93 = document.getElementById('u93');

var u94 = document.getElementById('u94');

var u95 = document.getElementById('u95');
gv_vAlignTable['u95'] = 'center';
var u96 = document.getElementById('u96');

u96.style.cursor = 'pointer';
if (bIE) u96.attachEvent("onclick", Clicku96);
else u96.addEventListener("click", Clicku96, true);
function Clicku96(e)
{
windowEvent = e;


if (true) {

	self.location.href="Features.html" + GetQuerystring();

}

}

var u97 = document.getElementById('u97');

var u98 = document.getElementById('u98');
gv_vAlignTable['u98'] = 'center';
var u99 = document.getElementById('u99');

var u128 = document.getElementById('u128');
gv_vAlignTable['u128'] = 'center';
var u129 = document.getElementById('u129');

var u278 = document.getElementById('u278');
gv_vAlignTable['u278'] = 'center';
var u279 = document.getElementById('u279');

u279.style.cursor = 'pointer';
if (bIE) u279.attachEvent("onclick", Clicku279);
else u279.addEventListener("click", Clicku279, true);
function Clicku279(e)
{
windowEvent = e;


if (true) {

if (IsWidgetSelected('u279')) {
SetWidgetNotSelected('u279'); } else {
SetWidgetSelected('u279');
}
}

}

var u130 = document.getElementById('u130');
gv_vAlignTable['u130'] = 'center';
var u131 = document.getElementById('u131');

u131.style.cursor = 'pointer';
if (bIE) u131.attachEvent("onclick", Clicku131);
else u131.addEventListener("click", Clicku131, true);
function Clicku131(e)
{
windowEvent = e;


if (true) {

	self.location.href="Features.html" + GetQuerystring();

}

}

var u132 = document.getElementById('u132');
gv_vAlignTable['u132'] = 'center';
var u133 = document.getElementById('u133');

var u134 = document.getElementById('u134');
gv_vAlignTable['u134'] = 'top';
var u135 = document.getElementById('u135');
gv_vAlignTable['u135'] = 'top';
var u136 = document.getElementById('u136');

var u137 = document.getElementById('u137');

var u138 = document.getElementById('u138');
gv_vAlignTable['u138'] = 'top';
var u139 = document.getElementById('u139');

var u140 = document.getElementById('u140');

var u141 = document.getElementById('u141');
gv_vAlignTable['u141'] = 'center';
var u142 = document.getElementById('u142');

var u143 = document.getElementById('u143');
gv_vAlignTable['u143'] = 'center';
var u144 = document.getElementById('u144');

var u145 = document.getElementById('u145');
gv_vAlignTable['u145'] = 'center';
var u146 = document.getElementById('u146');

var u147 = document.getElementById('u147');
gv_vAlignTable['u147'] = 'center';
var u148 = document.getElementById('u148');

u148.style.cursor = 'pointer';
if (bIE) u148.attachEvent("onclick", Clicku148);
else u148.addEventListener("click", Clicku148, true);
function Clicku148(e)
{
windowEvent = e;


if (true) {

	SetPanelVisibility('u191','','none',500);

	SetPanelState('u191', 'pd2u191','none','',500,'none','',500);

}

}
gv_vAlignTable['u148'] = 'top';
var u149 = document.getElementById('u149');

var u150 = document.getElementById('u150');
gv_vAlignTable['u150'] = 'center';
var u151 = document.getElementById('u151');

var u152 = document.getElementById('u152');
gv_vAlignTable['u152'] = 'center';
var u153 = document.getElementById('u153');
gv_vAlignTable['u153'] = 'top';
var u154 = document.getElementById('u154');
gv_vAlignTable['u154'] = 'top';
var u155 = document.getElementById('u155');

u155.style.cursor = 'pointer';
if (bIE) u155.attachEvent("onclick", Clicku155);
else u155.addEventListener("click", Clicku155, true);
function Clicku155(e)
{
windowEvent = e;


if (true) {

	SetPanelVisibility('u191','','none',500);

	SetPanelState('u191', 'pd0u191','none','',500,'fade','',200);

}

}

var u156 = document.getElementById('u156');
gv_vAlignTable['u156'] = 'center';
var u157 = document.getElementById('u157');

var u158 = document.getElementById('u158');
gv_vAlignTable['u158'] = 'center';
var u159 = document.getElementById('u159');

var u234 = document.getElementById('u234');
gv_vAlignTable['u234'] = 'top';
var u235 = document.getElementById('u235');

var u284 = document.getElementById('u284');
gv_vAlignTable['u284'] = 'center';
var u285 = document.getElementById('u285');

u285.style.cursor = 'pointer';
if (bIE) u285.attachEvent("onclick", Clicku285);
else u285.addEventListener("click", Clicku285, true);
function Clicku285(e)
{
windowEvent = e;


if (true) {

	self.location.href="Header.html" + GetQuerystring();

}

}
gv_vAlignTable['u285'] = 'top';
var u286 = document.getElementById('u286');
gv_vAlignTable['u286'] = 'top';
var u287 = document.getElementById('u287');

var u160 = document.getElementById('u160');
gv_vAlignTable['u160'] = 'center';
var u161 = document.getElementById('u161');

var u162 = document.getElementById('u162');
gv_vAlignTable['u162'] = 'center';
var u163 = document.getElementById('u163');

var u164 = document.getElementById('u164');

var u165 = document.getElementById('u165');
gv_vAlignTable['u165'] = 'center';
var u166 = document.getElementById('u166');

var u167 = document.getElementById('u167');
gv_vAlignTable['u167'] = 'center';
var u168 = document.getElementById('u168');

var u169 = document.getElementById('u169');
gv_vAlignTable['u169'] = 'center';
var u170 = document.getElementById('u170');

var u171 = document.getElementById('u171');
gv_vAlignTable['u171'] = 'center';
var u172 = document.getElementById('u172');

var u173 = document.getElementById('u173');

var u174 = document.getElementById('u174');
gv_vAlignTable['u174'] = 'center';
var u175 = document.getElementById('u175');

var u176 = document.getElementById('u176');

var u177 = document.getElementById('u177');
gv_vAlignTable['u177'] = 'center';
var u178 = document.getElementById('u178');

u178.style.cursor = 'pointer';
if (bIE) u178.attachEvent("onclick", Clicku178);
else u178.addEventListener("click", Clicku178, true);
function Clicku178(e)
{
windowEvent = e;


if (true) {

	SetPanelVisibility('u191','','none',500);

	SetPanelState('u191', 'pd2u191','none','',500,'none','',500);

}

}
gv_vAlignTable['u178'] = 'top';
var u179 = document.getElementById('u179');

var u251 = document.getElementById('u251');
gv_vAlignTable['u251'] = 'top';
var u252 = document.getElementById('u252');

var u253 = document.getElementById('u253');
gv_vAlignTable['u253'] = 'center';
var u200 = document.getElementById('u200');

var u72 = document.getElementById('u72');
gv_vAlignTable['u72'] = 'center';
var u73 = document.getElementById('u73');

u73.style.cursor = 'pointer';
if (bIE) u73.attachEvent("onclick", Clicku73);
else u73.addEventListener("click", Clicku73, true);
function Clicku73(e)
{
windowEvent = e;


if (true) {

	self.location.href="Keywords.html" + GetQuerystring();

}

}

var u74 = document.getElementById('u74');

var u75 = document.getElementById('u75');
gv_vAlignTable['u75'] = 'center';
var u76 = document.getElementById('u76');

u76.style.cursor = 'pointer';
if (bIE) u76.attachEvent("onclick", Clicku76);
else u76.addEventListener("click", Clicku76, true);
function Clicku76(e)
{
windowEvent = e;


if (true) {

	self.location.href="Article_Comments.html" + GetQuerystring();

}

}

var u77 = document.getElementById('u77');

var u78 = document.getElementById('u78');
gv_vAlignTable['u78'] = 'center';
var u79 = document.getElementById('u79');

var u180 = document.getElementById('u180');
gv_vAlignTable['u180'] = 'center';
var u181 = document.getElementById('u181');

u181.style.cursor = 'pointer';
if (bIE) u181.attachEvent("onclick", Clicku181);
else u181.addEventListener("click", Clicku181, true);
function Clicku181(e)
{
windowEvent = e;


if (true) {

	SetPanelVisibility('u191','','none',500);

	SetPanelState('u191', 'pd2u191','none','',500,'none','',500);

}

}
gv_vAlignTable['u181'] = 'top';
var u182 = document.getElementById('u182');

var u183 = document.getElementById('u183');
gv_vAlignTable['u183'] = 'center';
var u184 = document.getElementById('u184');

u184.style.cursor = 'pointer';
if (bIE) u184.attachEvent("onclick", Clicku184);
else u184.addEventListener("click", Clicku184, true);
function Clicku184(e)
{
windowEvent = e;


if (true) {

	SetPanelVisibility('u191','','none',500);

	SetPanelState('u191', 'pd2u191','none','',500,'none','',500);

}

}
gv_vAlignTable['u184'] = 'top';
var u185 = document.getElementById('u185');

u185.style.cursor = 'pointer';
if (bIE) u185.attachEvent("onclick", Clicku185);
else u185.addEventListener("click", Clicku185, true);
function Clicku185(e)
{
windowEvent = e;


if (true) {

	SetPanelVisibility('u191','','none',500);

	SetPanelState('u191', 'pd1u191','none','',500,'none','',500);

}

}

var u186 = document.getElementById('u186');
gv_vAlignTable['u186'] = 'center';
var u187 = document.getElementById('u187');

u187.style.cursor = 'pointer';
if (bIE) u187.attachEvent("onclick", Clicku187);
else u187.addEventListener("click", Clicku187, true);
function Clicku187(e)
{
windowEvent = e;


if (true) {

	SetPanelVisibility('u191','','none',500);

	SetPanelState('u191', 'pd1u191','none','',500,'none','',500);

}

}

var u188 = document.getElementById('u188');
gv_vAlignTable['u188'] = 'center';
var u189 = document.getElementById('u189');

u189.style.cursor = 'pointer';
if (bIE) u189.attachEvent("onclick", Clicku189);
else u189.addEventListener("click", Clicku189, true);
function Clicku189(e)
{
windowEvent = e;


if (true) {

	SetPanelVisibility('u191','','none',500);

	SetPanelState('u191', 'pd1u191','none','',500,'none','',500);

}

}

var u260 = document.getElementById('u260');

var u262 = document.getElementById('u262');
gv_vAlignTable['u262'] = 'center';
var u263 = document.getElementById('u263');

var u210 = document.getElementById('u210');
gv_vAlignTable['u210'] = 'center';
var u266 = document.getElementById('u266');

var u267 = document.getElementById('u267');
gv_vAlignTable['u267'] = 'center';
var u213 = document.getElementById('u213');
gv_vAlignTable['u213'] = 'top';
var u214 = document.getElementById('u214');

u214.style.cursor = 'pointer';
if (bIE) u214.attachEvent("onclick", Clicku214);
else u214.addEventListener("click", Clicku214, true);
function Clicku214(e)
{
windowEvent = e;


if (true) {

	SetPanelVisibility('u191','hidden','none',500);

}

}

var u215 = document.getElementById('u215');
gv_vAlignTable['u215'] = 'center';
var u190 = document.getElementById('u190');
gv_vAlignTable['u190'] = 'center';
var u191 = document.getElementById('u191');

var u192 = document.getElementById('u192');

var u193 = document.getElementById('u193');
gv_vAlignTable['u193'] = 'center';
var u194 = document.getElementById('u194');

var u195 = document.getElementById('u195');
gv_vAlignTable['u195'] = 'center';
var u196 = document.getElementById('u196');
gv_vAlignTable['u196'] = 'top';
var u197 = document.getElementById('u197');

u197.style.cursor = 'pointer';
if (bIE) u197.attachEvent("onclick", Clicku197);
else u197.addEventListener("click", Clicku197, true);
function Clicku197(e)
{
windowEvent = e;


if (true) {

	SetPanelVisibility('u191','hidden','none',500);

}

}

var u198 = document.getElementById('u198');
gv_vAlignTable['u198'] = 'center';
var u199 = document.getElementById('u199');
gv_vAlignTable['u199'] = 'top';
var u272 = document.getElementById('u272');

var u220 = document.getElementById('u220');
gv_vAlignTable['u220'] = 'top';
var u275 = document.getElementById('u275');

u275.style.cursor = 'pointer';
if (bIE) u275.attachEvent("onclick", Clicku275);
else u275.addEventListener("click", Clicku275, true);
function Clicku275(e)
{
windowEvent = e;


if (true) {

	SetPanelVisibility('u191','hidden','none',500);

}

}

var u276 = document.getElementById('u276');
gv_vAlignTable['u276'] = 'center';
var u277 = document.getElementById('u277');

u277.style.cursor = 'pointer';
if (bIE) u277.attachEvent("onclick", Clicku277);
else u277.addEventListener("click", Clicku277, true);
function Clicku277(e)
{
windowEvent = e;


if (true) {

	SetPanelVisibility('u191','hidden','none',500);

}

}

var u224 = document.getElementById('u224');
gv_vAlignTable['u224'] = 'center';
var u225 = document.getElementById('u225');
gv_vAlignTable['u225'] = 'top';
var u0 = document.getElementById('u0');

var u1 = document.getElementById('u1');
gv_vAlignTable['u1'] = 'center';
var u2 = document.getElementById('u2');

var u3 = document.getElementById('u3');
gv_vAlignTable['u3'] = 'center';
var u4 = document.getElementById('u4');

if (bIE) u4.attachEvent("onchange", Changeu4);
else u4.addEventListener("change", Changeu4, true);
function Changeu4(e)
{
windowEvent = e;


if ((GetSelectedOption('u4')) == ('新闻控制台')) {

	self.location.href="My_Published_Posts.html" + GetQuerystring();

}
else
if ((GetSelectedOption('u4')) == ('社区控制台')) {

	self.location.href="Community_Console.html" + GetQuerystring();

}
else
if ((GetSelectedOption('u4')) == ('通用控制台')) {

	self.location.href="General_Console.html" + GetQuerystring();

}

}

var u5 = document.getElementById('u5');

var u6 = document.getElementById('u6');
gv_vAlignTable['u6'] = 'center';
var u7 = document.getElementById('u7');

if (bIE) u7.attachEvent("onfocus", Focusu7);
else u7.addEventListener("focus", Focusu7, true);
function Focusu7(e)
{
windowEvent = e;


if (true) {

SetWidgetFormText('u7', '');

}

}

if (bIE) u7.attachEvent("onblur", LostFocusu7);
else u7.addEventListener("blur", LostFocusu7, true);
function LostFocusu7(e)
{
windowEvent = e;


if (true) {

SetWidgetFormText('u7', '文章标题，关键词，内容...');

}

}

var u8 = document.getElementById('u8');

u8.style.cursor = 'pointer';
if (bIE) u8.attachEvent("onclick", Clicku8);
else u8.addEventListener("click", Clicku8, true);
function Clicku8(e)
{
windowEvent = e;


if (true) {

	self.location.href="Article_Search.html" + GetQuerystring();

}

}

var u9 = document.getElementById('u9');

var u240 = document.getElementById('u240');
gv_vAlignTable['u240'] = 'center';
var u241 = document.getElementById('u241');
gv_vAlignTable['u241'] = 'top';
var u242 = document.getElementById('u242');

var u243 = document.getElementById('u243');
gv_vAlignTable['u243'] = 'center';
var u244 = document.getElementById('u244');

var u245 = document.getElementById('u245');
gv_vAlignTable['u245'] = 'top';
var u10 = document.getElementById('u10');

var u11 = document.getElementById('u11');
gv_vAlignTable['u11'] = 'center';
var u12 = document.getElementById('u12');
gv_vAlignTable['u12'] = 'top';
var u13 = document.getElementById('u13');
gv_vAlignTable['u13'] = 'top';
var u14 = document.getElementById('u14');

var u15 = document.getElementById('u15');

var u16 = document.getElementById('u16');
gv_vAlignTable['u16'] = 'center';
var u17 = document.getElementById('u17');

var u18 = document.getElementById('u18');

u18.style.cursor = 'pointer';
if (bIE) u18.attachEvent("onclick", Clicku18);
else u18.addEventListener("click", Clicku18, true);
function Clicku18(e)
{
windowEvent = e;


if (true) {

	self.location.href="My_Published_Posts.html" + GetQuerystring();

}

}

var u19 = document.getElementById('u19');

var u110 = document.getElementById('u110');

u110.style.cursor = 'pointer';
if (bIE) u110.attachEvent("onclick", Clicku110);
else u110.addEventListener("click", Clicku110, true);
function Clicku110(e)
{
windowEvent = e;


if (true) {

	self.location.href="Daily_Newspaper.html" + GetQuerystring();

}

}

var u111 = document.getElementById('u111');

var u112 = document.getElementById('u112');
gv_vAlignTable['u112'] = 'center';
var u113 = document.getElementById('u113');

var u114 = document.getElementById('u114');
gv_vAlignTable['u114'] = 'center';
var u250 = document.getElementById('u250');
gv_vAlignTable['u250'] = 'center';
var u115 = document.getElementById('u115');

u115.style.cursor = 'pointer';
if (bIE) u115.attachEvent("onclick", Clicku115);
else u115.addEventListener("click", Clicku115, true);
function Clicku115(e)
{
windowEvent = e;


if (true) {

	self.location.href="Daily_Newspaper.html" + GetQuerystring();

}

}

var u116 = document.getElementById('u116');

var u117 = document.getElementById('u117');
gv_vAlignTable['u117'] = 'center';
var u254 = document.getElementById('u254');

var u255 = document.getElementById('u255');
gv_vAlignTable['u255'] = 'center';
var u256 = document.getElementById('u256');
gv_vAlignTable['u256'] = 'top';
var u20 = document.getElementById('u20');
gv_vAlignTable['u20'] = 'center';
var u21 = document.getElementById('u21');

var u22 = document.getElementById('u22');
gv_vAlignTable['u22'] = 'center';
var u23 = document.getElementById('u23');

u23.style.cursor = 'pointer';
if (bIE) u23.attachEvent("onclick", Clicku23);
else u23.addEventListener("click", Clicku23, true);
function Clicku23(e)
{
windowEvent = e;


if (true) {

	self.location.href="Daily_Articles.html" + GetQuerystring();

}

}

var u24 = document.getElementById('u24');

var u25 = document.getElementById('u25');
gv_vAlignTable['u25'] = 'center';
var u26 = document.getElementById('u26');

u26.style.cursor = 'pointer';
if (bIE) u26.attachEvent("onclick", Clicku26);
else u26.addEventListener("click", Clicku26, true);
function Clicku26(e)
{
windowEvent = e;


if (true) {

	self.location.href="My_Published_Posts.html" + GetQuerystring();

}

}

var u27 = document.getElementById('u27');

var u28 = document.getElementById('u28');
gv_vAlignTable['u28'] = 'center';
var u29 = document.getElementById('u29');

u29.style.cursor = 'pointer';
if (bIE) u29.attachEvent("onclick", Clicku29);
else u29.addEventListener("click", Clicku29, true);
function Clicku29(e)
{
windowEvent = e;


if (true) {

	self.location.href="My_Draft.html" + GetQuerystring();

}

}

var u206 = document.getElementById('u206');
gv_vAlignTable['u206'] = 'center';
var u207 = document.getElementById('u207');

var u208 = document.getElementById('u208');
gv_vAlignTable['u208'] = 'center';
var u209 = document.getElementById('u209');

var u120 = document.getElementById('u120');
gv_vAlignTable['u120'] = 'center';
var u121 = document.getElementById('u121');

var u122 = document.getElementById('u122');

var u123 = document.getElementById('u123');
gv_vAlignTable['u123'] = 'top';
var u124 = document.getElementById('u124');

var u125 = document.getElementById('u125');
gv_vAlignTable['u125'] = 'center';
var u261 = document.getElementById('u261');

var u126 = document.getElementById('u126');

var u127 = document.getElementById('u127');

u127.style.cursor = 'pointer';
if (bIE) u127.attachEvent("onclick", Clicku127);
else u127.addEventListener("click", Clicku127, true);
function Clicku127(e)
{
windowEvent = e;


if (true) {

	self.location.href="My_Draft.html" + GetQuerystring();

}

}

var u264 = document.getElementById('u264');
gv_vAlignTable['u264'] = 'center';
var u265 = document.getElementById('u265');

var u30 = document.getElementById('u30');

var u31 = document.getElementById('u31');
gv_vAlignTable['u31'] = 'center';
var u32 = document.getElementById('u32');

var u33 = document.getElementById('u33');

var u34 = document.getElementById('u34');
gv_vAlignTable['u34'] = 'center';
var u35 = document.getElementById('u35');

var u36 = document.getElementById('u36');

var u37 = document.getElementById('u37');
gv_vAlignTable['u37'] = 'center';
var u38 = document.getElementById('u38');

var u39 = document.getElementById('u39');

var u216 = document.getElementById('u216');

var u217 = document.getElementById('u217');
gv_vAlignTable['u217'] = 'top';
var u218 = document.getElementById('u218');

var u219 = document.getElementById('u219');
gv_vAlignTable['u219'] = 'center';
var u201 = document.getElementById('u201');

var u202 = document.getElementById('u202');
gv_vAlignTable['u202'] = 'center';
var u203 = document.getElementById('u203');

u203.style.cursor = 'pointer';
if (bIE) u203.attachEvent("onclick", Clicku203);
else u203.addEventListener("click", Clicku203, true);
function Clicku203(e)
{
windowEvent = e;


if (true) {

	SetPanelVisibility('u191','hidden','none',500);

}

}

var u204 = document.getElementById('u204');
gv_vAlignTable['u204'] = 'center';
var u205 = document.getElementById('u205');

u205.style.cursor = 'pointer';
if (bIE) u205.attachEvent("onclick", Clicku205);
else u205.addEventListener("click", Clicku205, true);
function Clicku205(e)
{
windowEvent = e;


if (true) {

	SetPanelVisibility('u191','hidden','none',500);

}

}

var u270 = document.getElementById('u270');
gv_vAlignTable['u270'] = 'center';
var u271 = document.getElementById('u271');

var u257 = document.getElementById('u257');

u257.style.cursor = 'pointer';
if (bIE) u257.attachEvent("onclick", Clicku257);
else u257.addEventListener("click", Clicku257, true);
function Clicku257(e)
{
windowEvent = e;


if (true) {

	SetPanelVisibility('u191','hidden','none',500);

}

}

var u273 = document.getElementById('u273');

var u274 = document.getElementById('u274');

var u40 = document.getElementById('u40');
gv_vAlignTable['u40'] = 'center';
var u41 = document.getElementById('u41');

u41.style.cursor = 'pointer';
if (bIE) u41.attachEvent("onclick", Clicku41);
else u41.addEventListener("click", Clicku41, true);
function Clicku41(e)
{
windowEvent = e;


if (true) {

	self.location.href="Daily_All.html" + GetQuerystring();

}

}

var u42 = document.getElementById('u42');

var u43 = document.getElementById('u43');
gv_vAlignTable['u43'] = 'center';
var u44 = document.getElementById('u44');

var u45 = document.getElementById('u45');
gv_vAlignTable['u45'] = 'center';
var u46 = document.getElementById('u46');

u46.style.cursor = 'pointer';
if (bIE) u46.attachEvent("onclick", Clicku46);
else u46.addEventListener("click", Clicku46, true);
function Clicku46(e)
{
windowEvent = e;


if (true) {

	self.location.href="Daily_All.html" + GetQuerystring();

}

}

var u47 = document.getElementById('u47');

var u48 = document.getElementById('u48');
gv_vAlignTable['u48'] = 'center';
var u49 = document.getElementById('u49');

u49.style.cursor = 'pointer';
if (bIE) u49.attachEvent("onclick", Clicku49);
else u49.addEventListener("click", Clicku49, true);
function Clicku49(e)
{
windowEvent = e;


if (true) {

	self.location.href="News_Console.html" + GetQuerystring();

}

}

var u226 = document.getElementById('u226');

var u227 = document.getElementById('u227');
gv_vAlignTable['u227'] = 'center';
var u228 = document.getElementById('u228');

var u229 = document.getElementById('u229');
gv_vAlignTable['u229'] = 'center';
var u211 = document.getElementById('u211');

var u212 = document.getElementById('u212');
gv_vAlignTable['u212'] = 'center';
var u280 = document.getElementById('u280');
gv_vAlignTable['u280'] = 'center';
var u281 = document.getElementById('u281');
gv_vAlignTable['u281'] = 'top';
var u282 = document.getElementById('u282');
gv_vAlignTable['u282'] = 'top';
var u283 = document.getElementById('u283');

var u50 = document.getElementById('u50');

var u51 = document.getElementById('u51');
gv_vAlignTable['u51'] = 'center';
var u52 = document.getElementById('u52');

u52.style.cursor = 'pointer';
if (bIE) u52.attachEvent("onclick", Clicku52);
else u52.addEventListener("click", Clicku52, true);
function Clicku52(e)
{
windowEvent = e;


if (true) {

	self.location.href="News_Channel.html" + GetQuerystring();

}

}

var u53 = document.getElementById('u53');

var u54 = document.getElementById('u54');
gv_vAlignTable['u54'] = 'center';
var u55 = document.getElementById('u55');

u55.style.cursor = 'pointer';
if (bIE) u55.attachEvent("onclick", Clicku55);
else u55.addEventListener("click", Clicku55, true);
function Clicku55(e)
{
windowEvent = e;


if (true) {

	self.location.href="Market_Channel.html" + GetQuerystring();

}

}

var u56 = document.getElementById('u56');

var u57 = document.getElementById('u57');
gv_vAlignTable['u57'] = 'center';
var u58 = document.getElementById('u58');

u58.style.cursor = 'pointer';
if (bIE) u58.attachEvent("onclick", Clicku58);
else u58.addEventListener("click", Clicku58, true);
function Clicku58(e)
{
windowEvent = e;


if (true) {

	self.location.href="Business_Channel.html" + GetQuerystring();

}

}

var u59 = document.getElementById('u59');

var u236 = document.getElementById('u236');
gv_vAlignTable['u236'] = 'center';
var u237 = document.getElementById('u237');

var u238 = document.getElementById('u238');
gv_vAlignTable['u238'] = 'top';
var u239 = document.getElementById('u239');

var u221 = document.getElementById('u221');

var u222 = document.getElementById('u222');
gv_vAlignTable['u222'] = 'top';
var u223 = document.getElementById('u223');

var u60 = document.getElementById('u60');
gv_vAlignTable['u60'] = 'center';
var u61 = document.getElementById('u61');

u61.style.cursor = 'pointer';
if (bIE) u61.attachEvent("onclick", Clicku61);
else u61.addEventListener("click", Clicku61, true);
function Clicku61(e)
{
windowEvent = e;


if (true) {

	self.location.href="Global_Channel.html" + GetQuerystring();

}

}

var u62 = document.getElementById('u62');

var u63 = document.getElementById('u63');
gv_vAlignTable['u63'] = 'center';
var u64 = document.getElementById('u64');

u64.style.cursor = 'pointer';
if (bIE) u64.attachEvent("onclick", Clicku64);
else u64.addEventListener("click", Clicku64, true);
function Clicku64(e)
{
windowEvent = e;


if (true) {

	self.location.href="Viewpoint_Channel.html" + GetQuerystring();

}

}

var u65 = document.getElementById('u65');

var u66 = document.getElementById('u66');
gv_vAlignTable['u66'] = 'center';
var u67 = document.getElementById('u67');

u67.style.cursor = 'pointer';
if (bIE) u67.attachEvent("onclick", Clicku67);
else u67.addEventListener("click", Clicku67, true);
function Clicku67(e)
{
windowEvent = e;


if (true) {

	self.location.href="Life_Channel.html" + GetQuerystring();

}

}

var u68 = document.getElementById('u68');

var u69 = document.getElementById('u69');
gv_vAlignTable['u69'] = 'center';
var u246 = document.getElementById('u246');

var u247 = document.getElementById('u247');
gv_vAlignTable['u247'] = 'center';
var u248 = document.getElementById('u248');
gv_vAlignTable['u248'] = 'top';
var u249 = document.getElementById('u249');

if (window.OnLoad) OnLoad();
