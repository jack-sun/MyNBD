
var PageName = 'Add New Feature';
var PageId = '781467abf6ac446e854cdc2a55818033'
var PageUrl = 'Add_New_Feature.html'
document.title = 'Add New Feature';
var PageNotes = 
{
"pageName":"Add New Feature",
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
  value = value.replace(/\[\[GenDay\]\]/g, '9');
  value = value.replace(/\[\[GenMonth\]\]/g, '10');
  value = value.replace(/\[\[GenMonthName\]\]/g, 'October');
  value = value.replace(/\[\[GenDayOfWeek\]\]/g, 'Sunday');
  value = value.replace(/\[\[GenYear\]\]/g, '2011');
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
gv_vAlignTable['u230'] = 'top';
var u231 = document.getElementById('u231');

var u232 = document.getElementById('u232');
gv_vAlignTable['u232'] = 'center';
var u233 = document.getElementById('u233');
gv_vAlignTable['u233'] = 'top';
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

var u101 = document.getElementById('u101');
gv_vAlignTable['u101'] = 'center';
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

	self.location.href="Features.html" + GetQuerystring();

}

}

var u105 = document.getElementById('u105');

var u106 = document.getElementById('u106');
gv_vAlignTable['u106'] = 'center';
var u107 = document.getElementById('u107');

u107.style.cursor = 'pointer';
if (bIE) u107.attachEvent("onclick", Clicku107);
else u107.addEventListener("click", Clicku107, true);
function Clicku107(e)
{
windowEvent = e;


if (true) {

	self.location.href="resources/reload.html#" + encodeURI(PageUrl + GetQuerystring());

}

}

var u108 = document.getElementById('u108');

var u109 = document.getElementById('u109');
gv_vAlignTable['u109'] = 'center';
var u258 = document.getElementById('u258');
gv_vAlignTable['u258'] = 'top';
var u259 = document.getElementById('u259');

var u80 = document.getElementById('u80');

var u81 = document.getElementById('u81');
gv_vAlignTable['u81'] = 'center';
var u82 = document.getElementById('u82');

var u83 = document.getElementById('u83');

var u84 = document.getElementById('u84');
gv_vAlignTable['u84'] = 'center';
var u85 = document.getElementById('u85');

u85.style.cursor = 'pointer';
if (bIE) u85.attachEvent("onclick", Clicku85);
else u85.addEventListener("click", Clicku85, true);
function Clicku85(e)
{
windowEvent = e;


if (true) {

	self.location.href="Media_Library.html" + GetQuerystring();

}

}

var u86 = document.getElementById('u86');

var u87 = document.getElementById('u87');
gv_vAlignTable['u87'] = 'center';
var u88 = document.getElementById('u88');

var u89 = document.getElementById('u89');
gv_vAlignTable['u89'] = 'center';
var u118 = document.getElementById('u118');

u118.style.cursor = 'pointer';
if (bIE) u118.attachEvent("onclick", Clicku118);
else u118.addEventListener("click", Clicku118, true);
function Clicku118(e)
{
windowEvent = e;


if (true) {

	self.location.href="Daily_Newspaper.html" + GetQuerystring();

}

}

var u119 = document.getElementById('u119');

var u268 = document.getElementById('u268');
gv_vAlignTable['u268'] = 'center';
var u269 = document.getElementById('u269');
gv_vAlignTable['u269'] = 'top';
var u90 = document.getElementById('u90');

u90.style.cursor = 'pointer';
if (bIE) u90.attachEvent("onclick", Clicku90);
else u90.addEventListener("click", Clicku90, true);
function Clicku90(e)
{
windowEvent = e;


if (true) {

	self.location.href="Add_Media_Files.html" + GetQuerystring();

}

}

var u91 = document.getElementById('u91');

var u92 = document.getElementById('u92');
gv_vAlignTable['u92'] = 'center';
var u93 = document.getElementById('u93');

u93.style.cursor = 'pointer';
if (bIE) u93.attachEvent("onclick", Clicku93);
else u93.addEventListener("click", Clicku93, true);
function Clicku93(e)
{
windowEvent = e;


if (true) {

	self.location.href="Media_Library.html" + GetQuerystring();

}

}

var u94 = document.getElementById('u94');

var u95 = document.getElementById('u95');
gv_vAlignTable['u95'] = 'center';
var u96 = document.getElementById('u96');

var u97 = document.getElementById('u97');

var u98 = document.getElementById('u98');
gv_vAlignTable['u98'] = 'center';
var u99 = document.getElementById('u99');

u99.style.cursor = 'pointer';
if (bIE) u99.attachEvent("onclick", Clicku99);
else u99.addEventListener("click", Clicku99, true);
function Clicku99(e)
{
windowEvent = e;


if (true) {

	self.location.href="Features.html" + GetQuerystring();

}

}

var u128 = document.getElementById('u128');
gv_vAlignTable['u128'] = 'center';
var u129 = document.getElementById('u129');
gv_vAlignTable['u129'] = 'top';
var u278 = document.getElementById('u278');

var u279 = document.getElementById('u279');

var u130 = document.getElementById('u130');

var u131 = document.getElementById('u131');

var u132 = document.getElementById('u132');

var u133 = document.getElementById('u133');
gv_vAlignTable['u133'] = 'top';
var u134 = document.getElementById('u134');

var u135 = document.getElementById('u135');

var u136 = document.getElementById('u136');

var u137 = document.getElementById('u137');

u137.style.cursor = 'pointer';
if (bIE) u137.attachEvent("onclick", Clicku137);
else u137.addEventListener("click", Clicku137, true);
function Clicku137(e)
{
windowEvent = e;


if (true) {

	self.location.href="My_Draft.html" + GetQuerystring();

}

}

var u138 = document.getElementById('u138');
gv_vAlignTable['u138'] = 'center';
var u139 = document.getElementById('u139');

var u288 = document.getElementById('u288');

u288.style.cursor = 'pointer';
if (bIE) u288.attachEvent("onclick", Clicku288);
else u288.addEventListener("click", Clicku288, true);
function Clicku288(e)
{
windowEvent = e;


if (true) {

	SetPanelVisibility('u204','hidden','none',500);

}

}

var u289 = document.getElementById('u289');
gv_vAlignTable['u289'] = 'center';
var u140 = document.getElementById('u140');
gv_vAlignTable['u140'] = 'center';
var u141 = document.getElementById('u141');

u141.style.cursor = 'pointer';
if (bIE) u141.attachEvent("onclick", Clicku141);
else u141.addEventListener("click", Clicku141, true);
function Clicku141(e)
{
windowEvent = e;


if (true) {

	self.location.href="Features.html" + GetQuerystring();

}

}

var u142 = document.getElementById('u142');
gv_vAlignTable['u142'] = 'center';
var u143 = document.getElementById('u143');

var u144 = document.getElementById('u144');

u144.style.cursor = 'pointer';
if (bIE) u144.attachEvent("onclick", Clicku144);
else u144.addEventListener("click", Clicku144, true);
function Clicku144(e)
{
windowEvent = e;


if (true) {

	self.location.href="javascript:history.back()";

}

}
gv_vAlignTable['u144'] = 'top';
var u145 = document.getElementById('u145');
gv_vAlignTable['u145'] = 'top';
var u146 = document.getElementById('u146');
gv_vAlignTable['u146'] = 'top';
var u147 = document.getElementById('u147');

var u148 = document.getElementById('u148');

var u149 = document.getElementById('u149');
gv_vAlignTable['u149'] = 'top';
var u150 = document.getElementById('u150');
gv_vAlignTable['u150'] = 'top';
var u151 = document.getElementById('u151');

var u152 = document.getElementById('u152');
gv_vAlignTable['u152'] = 'top';
var u153 = document.getElementById('u153');

var u154 = document.getElementById('u154');
gv_vAlignTable['u154'] = 'center';
var u155 = document.getElementById('u155');

var u156 = document.getElementById('u156');
gv_vAlignTable['u156'] = 'center';
var u157 = document.getElementById('u157');

var u158 = document.getElementById('u158');
gv_vAlignTable['u158'] = 'center';
var u159 = document.getElementById('u159');

var u234 = document.getElementById('u234');

var u235 = document.getElementById('u235');
gv_vAlignTable['u235'] = 'top';
var u284 = document.getElementById('u284');

var u285 = document.getElementById('u285');

var u286 = document.getElementById('u286');

var u287 = document.getElementById('u287');

var u160 = document.getElementById('u160');
gv_vAlignTable['u160'] = 'center';
var u161 = document.getElementById('u161');

u161.style.cursor = 'pointer';
if (bIE) u161.attachEvent("onclick", Clicku161);
else u161.addEventListener("click", Clicku161, true);
function Clicku161(e)
{
windowEvent = e;


if (true) {

	SetPanelVisibility('u204','','none',500);

	SetPanelState('u204', 'pd2u204','none','',500,'none','',500);

}

}
gv_vAlignTable['u161'] = 'top';
var u162 = document.getElementById('u162');

var u163 = document.getElementById('u163');
gv_vAlignTable['u163'] = 'center';
var u164 = document.getElementById('u164');

var u165 = document.getElementById('u165');
gv_vAlignTable['u165'] = 'center';
var u166 = document.getElementById('u166');
gv_vAlignTable['u166'] = 'top';
var u167 = document.getElementById('u167');
gv_vAlignTable['u167'] = 'top';
var u168 = document.getElementById('u168');

u168.style.cursor = 'pointer';
if (bIE) u168.attachEvent("onclick", Clicku168);
else u168.addEventListener("click", Clicku168, true);
function Clicku168(e)
{
windowEvent = e;


if (true) {

	SetPanelVisibility('u204','','none',500);

	SetPanelState('u204', 'pd0u204','none','',500,'fade','',200);

}

}

var u169 = document.getElementById('u169');
gv_vAlignTable['u169'] = 'center';
var u170 = document.getElementById('u170');

var u171 = document.getElementById('u171');
gv_vAlignTable['u171'] = 'center';
var u172 = document.getElementById('u172');

var u173 = document.getElementById('u173');
gv_vAlignTable['u173'] = 'center';
var u174 = document.getElementById('u174');

var u175 = document.getElementById('u175');
gv_vAlignTable['u175'] = 'center';
var u176 = document.getElementById('u176');

var u177 = document.getElementById('u177');

var u178 = document.getElementById('u178');
gv_vAlignTable['u178'] = 'center';
var u179 = document.getElementById('u179');

var u251 = document.getElementById('u251');
gv_vAlignTable['u251'] = 'top';
var u252 = document.getElementById('u252');

var u253 = document.getElementById('u253');
gv_vAlignTable['u253'] = 'center';
var u200 = document.getElementById('u200');

u200.style.cursor = 'pointer';
if (bIE) u200.attachEvent("onclick", Clicku200);
else u200.addEventListener("click", Clicku200, true);
function Clicku200(e)
{
windowEvent = e;


if (true) {

	SetPanelVisibility('u204','','none',500);

	SetPanelState('u204', 'pd1u204','none','',500,'none','',500);

}

}

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

	self.location.href="Banned_Articles.html" + GetQuerystring();

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

	self.location.href="Keywords.html" + GetQuerystring();

}

}

var u77 = document.getElementById('u77');

var u78 = document.getElementById('u78');
gv_vAlignTable['u78'] = 'center';
var u79 = document.getElementById('u79');

u79.style.cursor = 'pointer';
if (bIE) u79.attachEvent("onclick", Clicku79);
else u79.addEventListener("click", Clicku79, true);
function Clicku79(e)
{
windowEvent = e;


if (true) {

	self.location.href="Article_Comments.html" + GetQuerystring();

}

}

var u180 = document.getElementById('u180');
gv_vAlignTable['u180'] = 'center';
var u181 = document.getElementById('u181');

var u182 = document.getElementById('u182');
gv_vAlignTable['u182'] = 'center';
var u183 = document.getElementById('u183');

var u184 = document.getElementById('u184');
gv_vAlignTable['u184'] = 'center';
var u185 = document.getElementById('u185');

var u186 = document.getElementById('u186');

var u187 = document.getElementById('u187');
gv_vAlignTable['u187'] = 'center';
var u188 = document.getElementById('u188');

var u189 = document.getElementById('u189');

var u260 = document.getElementById('u260');
gv_vAlignTable['u260'] = 'center';
var u262 = document.getElementById('u262');

var u263 = document.getElementById('u263');
gv_vAlignTable['u263'] = 'center';
var u210 = document.getElementById('u210');

u210.style.cursor = 'pointer';
if (bIE) u210.attachEvent("onclick", Clicku210);
else u210.addEventListener("click", Clicku210, true);
function Clicku210(e)
{
windowEvent = e;


if (true) {

	SetPanelVisibility('u204','hidden','none',500);

}

}

var u266 = document.getElementById('u266');
gv_vAlignTable['u266'] = 'center';
var u267 = document.getElementById('u267');

var u213 = document.getElementById('u213');

var u214 = document.getElementById('u214');

var u215 = document.getElementById('u215');
gv_vAlignTable['u215'] = 'center';
var u190 = document.getElementById('u190');
gv_vAlignTable['u190'] = 'center';
var u191 = document.getElementById('u191');

u191.style.cursor = 'pointer';
if (bIE) u191.attachEvent("onclick", Clicku191);
else u191.addEventListener("click", Clicku191, true);
function Clicku191(e)
{
windowEvent = e;


if (true) {

	SetPanelVisibility('u204','','none',500);

	SetPanelState('u204', 'pd2u204','none','',500,'none','',500);

}

}
gv_vAlignTable['u191'] = 'top';
var u192 = document.getElementById('u192');

var u193 = document.getElementById('u193');
gv_vAlignTable['u193'] = 'center';
var u194 = document.getElementById('u194');

u194.style.cursor = 'pointer';
if (bIE) u194.attachEvent("onclick", Clicku194);
else u194.addEventListener("click", Clicku194, true);
function Clicku194(e)
{
windowEvent = e;


if (true) {

	SetPanelVisibility('u204','','none',500);

	SetPanelState('u204', 'pd2u204','none','',500,'none','',500);

}

}
gv_vAlignTable['u194'] = 'top';
var u195 = document.getElementById('u195');

var u196 = document.getElementById('u196');
gv_vAlignTable['u196'] = 'center';
var u197 = document.getElementById('u197');

u197.style.cursor = 'pointer';
if (bIE) u197.attachEvent("onclick", Clicku197);
else u197.addEventListener("click", Clicku197, true);
function Clicku197(e)
{
windowEvent = e;


if (true) {

	SetPanelVisibility('u204','','none',500);

	SetPanelState('u204', 'pd2u204','none','',500,'none','',500);

}

}
gv_vAlignTable['u197'] = 'top';
var u198 = document.getElementById('u198');

u198.style.cursor = 'pointer';
if (bIE) u198.attachEvent("onclick", Clicku198);
else u198.addEventListener("click", Clicku198, true);
function Clicku198(e)
{
windowEvent = e;


if (true) {

	SetPanelVisibility('u204','','none',500);

	SetPanelState('u204', 'pd1u204','none','',500,'none','',500);

}

}

var u199 = document.getElementById('u199');
gv_vAlignTable['u199'] = 'center';
var u257 = document.getElementById('u257');

var u220 = document.getElementById('u220');

var u275 = document.getElementById('u275');
gv_vAlignTable['u275'] = 'center';
var u276 = document.getElementById('u276');

var u277 = document.getElementById('u277');
gv_vAlignTable['u277'] = 'center';
var u224 = document.getElementById('u224');

var u225 = document.getElementById('u225');
gv_vAlignTable['u225'] = 'center';
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

var u242 = document.getElementById('u242');
gv_vAlignTable['u242'] = 'center';
var u243 = document.getElementById('u243');

var u244 = document.getElementById('u244');
gv_vAlignTable['u244'] = 'top';
var u245 = document.getElementById('u245');

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

var u111 = document.getElementById('u111');

var u112 = document.getElementById('u112');
gv_vAlignTable['u112'] = 'center';
var u113 = document.getElementById('u113');

u113.style.cursor = 'pointer';
if (bIE) u113.attachEvent("onclick", Clicku113);
else u113.addEventListener("click", Clicku113, true);
function Clicku113(e)
{
windowEvent = e;


if (true) {

	self.location.href="Daily_Newspaper.html" + GetQuerystring();

}

}

var u114 = document.getElementById('u114');

var u250 = document.getElementById('u250');

var u115 = document.getElementById('u115');
gv_vAlignTable['u115'] = 'center';
var u116 = document.getElementById('u116');

var u117 = document.getElementById('u117');
gv_vAlignTable['u117'] = 'center';
var u254 = document.getElementById('u254');
gv_vAlignTable['u254'] = 'top';
var u255 = document.getElementById('u255');

var u256 = document.getElementById('u256');
gv_vAlignTable['u256'] = 'center';
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
gv_vAlignTable['u209'] = 'top';
var u120 = document.getElementById('u120');
gv_vAlignTable['u120'] = 'center';
var u121 = document.getElementById('u121');

var u122 = document.getElementById('u122');

var u123 = document.getElementById('u123');
gv_vAlignTable['u123'] = 'center';
var u124 = document.getElementById('u124');

var u125 = document.getElementById('u125');

var u261 = document.getElementById('u261');
gv_vAlignTable['u261'] = 'top';
var u126 = document.getElementById('u126');
gv_vAlignTable['u126'] = 'top';
var u127 = document.getElementById('u127');

var u264 = document.getElementById('u264');
gv_vAlignTable['u264'] = 'top';
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

u216.style.cursor = 'pointer';
if (bIE) u216.attachEvent("onclick", Clicku216);
else u216.addEventListener("click", Clicku216, true);
function Clicku216(e)
{
windowEvent = e;


if (true) {

	SetPanelVisibility('u204','hidden','none',500);

}

}

var u217 = document.getElementById('u217');
gv_vAlignTable['u217'] = 'center';
var u218 = document.getElementById('u218');

u218.style.cursor = 'pointer';
if (bIE) u218.attachEvent("onclick", Clicku218);
else u218.addEventListener("click", Clicku218, true);
function Clicku218(e)
{
windowEvent = e;


if (true) {

	SetPanelVisibility('u204','hidden','none',500);

}

}

var u219 = document.getElementById('u219');
gv_vAlignTable['u219'] = 'center';
var u201 = document.getElementById('u201');
gv_vAlignTable['u201'] = 'center';
var u202 = document.getElementById('u202');

u202.style.cursor = 'pointer';
if (bIE) u202.attachEvent("onclick", Clicku202);
else u202.addEventListener("click", Clicku202, true);
function Clicku202(e)
{
windowEvent = e;


if (true) {

	SetPanelVisibility('u204','','none',500);

	SetPanelState('u204', 'pd1u204','none','',500,'none','',500);

}

}

var u203 = document.getElementById('u203');
gv_vAlignTable['u203'] = 'center';
var u204 = document.getElementById('u204');

var u205 = document.getElementById('u205');

var u270 = document.getElementById('u270');

u270.style.cursor = 'pointer';
if (bIE) u270.attachEvent("onclick", Clicku270);
else u270.addEventListener("click", Clicku270, true);
function Clicku270(e)
{
windowEvent = e;


if (true) {

	SetPanelVisibility('u204','hidden','none',500);

}

}

var u271 = document.getElementById('u271');
gv_vAlignTable['u271'] = 'center';
var u272 = document.getElementById('u272');

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
gv_vAlignTable['u226'] = 'top';
var u227 = document.getElementById('u227');

u227.style.cursor = 'pointer';
if (bIE) u227.attachEvent("onclick", Clicku227);
else u227.addEventListener("click", Clicku227, true);
function Clicku227(e)
{
windowEvent = e;


if (true) {

	SetPanelVisibility('u204','hidden','none',500);

}

}

var u228 = document.getElementById('u228');
gv_vAlignTable['u228'] = 'center';
var u229 = document.getElementById('u229');

var u211 = document.getElementById('u211');
gv_vAlignTable['u211'] = 'center';
var u212 = document.getElementById('u212');
gv_vAlignTable['u212'] = 'top';
var u280 = document.getElementById('u280');
gv_vAlignTable['u280'] = 'center';
var u281 = document.getElementById('u281');

var u282 = document.getElementById('u282');

var u283 = document.getElementById('u283');
gv_vAlignTable['u283'] = 'center';
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

var u237 = document.getElementById('u237');
gv_vAlignTable['u237'] = 'center';
var u238 = document.getElementById('u238');
gv_vAlignTable['u238'] = 'top';
var u239 = document.getElementById('u239');

var u221 = document.getElementById('u221');
gv_vAlignTable['u221'] = 'center';
var u222 = document.getElementById('u222');

var u223 = document.getElementById('u223');
gv_vAlignTable['u223'] = 'center';
var u290 = document.getElementById('u290');

u290.style.cursor = 'pointer';
if (bIE) u290.attachEvent("onclick", Clicku290);
else u290.addEventListener("click", Clicku290, true);
function Clicku290(e)
{
windowEvent = e;


if (true) {

	SetPanelVisibility('u204','hidden','none',500);

}

}

var u291 = document.getElementById('u291');
gv_vAlignTable['u291'] = 'center';
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
gv_vAlignTable['u246'] = 'center';
var u247 = document.getElementById('u247');
gv_vAlignTable['u247'] = 'top';
var u248 = document.getElementById('u248');

var u249 = document.getElementById('u249');
gv_vAlignTable['u249'] = 'center';
if (window.OnLoad) OnLoad();
