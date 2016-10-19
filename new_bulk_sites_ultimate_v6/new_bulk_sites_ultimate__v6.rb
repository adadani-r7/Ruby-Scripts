require 'csv'
require 'logger'
require 'set'
require 'nexpose'
require 'yaml'
require 'pry_debug'
require 'chronic'
require 'tzinfo'
include Nexpose



timezones = {
"Africa/Abidjan" => { :utc_offset => "+00:00",	:utc_offset_dst => "+00:00" },
"Africa/Accra" => { :utc_offset => "+00:00",	:utc_offset_dst => "+00:00" },
"Africa/Addis_Ababa" => { :utc_offset => "+03:00",	:utc_offset_dst => "+03:00" },
"Africa/Algiers" => { :utc_offset => "+01:00",	:utc_offset_dst => "+01:00" },
"Africa/Asmara" => { :utc_offset => "+03:00",	:utc_offset_dst => "+03:00" },
"Africa/Bamako" => { :utc_offset => "+00:00",	:utc_offset_dst => "+00:00" },
"Africa/Bangui" => { :utc_offset => "+01:00",	:utc_offset_dst => "+01:00" },
"Africa/Banjul" => { :utc_offset => "+00:00",	:utc_offset_dst => "+00:00" },
"Africa/Bissau" => { :utc_offset => "+00:00",	:utc_offset_dst => "+00:00" },
"Africa/Blantyre" => { :utc_offset => "+02:00",	:utc_offset_dst => "+02:00" },
"Africa/Brazzaville" => { :utc_offset => "+01:00",	:utc_offset_dst => "+01:00" },
"Africa/Bujumbura" => { :utc_offset => "+02:00",	:utc_offset_dst => "+02:00" },
"Africa/Cairo" => { :utc_offset => "+02:00",	:utc_offset_dst => "+02:00" },
"Africa/Casablanca" => { :utc_offset => "+00:00",	:utc_offset_dst => "+01:00" },
"Africa/Ceuta" => { :utc_offset => "+01:00",	:utc_offset_dst => "+02:00" },
"Africa/Conakry" => { :utc_offset => "+00:00",	:utc_offset_dst => "+00:00" },
"Africa/Dakar" => { :utc_offset => "+00:00",	:utc_offset_dst => "+00:00" },
"Africa/Dar_es_Salaam" => { :utc_offset => "+03:00",	:utc_offset_dst => "+03:00" },
"Africa/Djibouti" => { :utc_offset => "+03:00",	:utc_offset_dst => "+03:00" },
"Africa/Douala" => { :utc_offset => "+01:00",	:utc_offset_dst => "+01:00" },
"Africa/El_Aaiun" => { :utc_offset => "+00:00",	:utc_offset_dst => "+01:00" },
"Africa/Freetown" => { :utc_offset => "+00:00",	:utc_offset_dst => "+00:00" },
"Africa/Gaborone" => { :utc_offset => "+02:00",	:utc_offset_dst => "+02:00" },
"Africa/Harare" => { :utc_offset => "+02:00",	:utc_offset_dst => "+02:00" },
"Africa/Johannesburg" => { :utc_offset => "+02:00",	:utc_offset_dst => "+02:00" },
"Africa/Juba" => { :utc_offset => "+03:00",	:utc_offset_dst => "+03:00" },
"Africa/Kampala" => { :utc_offset => "+03:00",	:utc_offset_dst => "+03:00" },
"Africa/Khartoum" => { :utc_offset => "+03:00",	:utc_offset_dst => "+03:00" },
"Africa/Kigali" => { :utc_offset => "+02:00",	:utc_offset_dst => "+02:00" },
"Africa/Kinshasa" => { :utc_offset => "+01:00",	:utc_offset_dst => "+01:00" },
"Africa/Lagos" => { :utc_offset => "+01:00",	:utc_offset_dst => "+01:00" },
"Africa/Libreville" => { :utc_offset => "+01:00",	:utc_offset_dst => "+01:00" },
"Africa/Lome" => { :utc_offset => "+00:00",	:utc_offset_dst => "+00:00" },
"Africa/Luanda" => { :utc_offset => "+01:00",	:utc_offset_dst => "+01:00" },
"Africa/Lubumbashi" => { :utc_offset => "+02:00",	:utc_offset_dst => "+02:00" },
"Africa/Lusaka" => { :utc_offset => "+02:00",	:utc_offset_dst => "+02:00" },
"Africa/Malabo" => { :utc_offset => "+01:00",	:utc_offset_dst => "+01:00" },
"Africa/Maputo" => { :utc_offset => "+02:00",	:utc_offset_dst => "+02:00" },
"Africa/Maseru" => { :utc_offset => "+02:00",	:utc_offset_dst => "+02:00" },
"Africa/Mbabane" => { :utc_offset => "+02:00",	:utc_offset_dst => "+02:00" },
"Africa/Mogadishu" => { :utc_offset => "+03:00",	:utc_offset_dst => "+03:00" },
"Africa/Monrovia" => { :utc_offset => "+00:00",	:utc_offset_dst => "+00:00" },
"Africa/Nairobi" => { :utc_offset => "+03:00",	:utc_offset_dst => "+03:00" },
"Africa/Ndjamena" => { :utc_offset => "+01:00",	:utc_offset_dst => "+01:00" },
"Africa/Niamey" => { :utc_offset => "+01:00",	:utc_offset_dst => "+01:00" },
"Africa/Nouakchott" => { :utc_offset => "+00:00",	:utc_offset_dst => "+00:00" },
"Africa/Ouagadougou" => { :utc_offset => "+00:00",	:utc_offset_dst => "+00:00" },
"Africa/Porto-Novo" => { :utc_offset => "+01:00",	:utc_offset_dst => "+01:00" },
"Africa/Sao_Tome" => { :utc_offset => "+00:00",	:utc_offset_dst => "+00:00" },
"Africa/Timbuktu" => { :utc_offset => "+00:00",	:utc_offset_dst => "+00:00" },
"Africa/Tripoli" => { :utc_offset => "+02:00",	:utc_offset_dst => "+02:00" },
"Africa/Tunis" => { :utc_offset => "+01:00",	:utc_offset_dst => "+01:00" },
"Africa/Windhoek" => { :utc_offset => "+01:00",	:utc_offset_dst => "+02:00" },
"America/Adak" => { :utc_offset => "-10:00",	:utc_offset_dst => "-09:00" },
"America/Anchorage" => { :utc_offset => "-09:00",	:utc_offset_dst => "-08:00" },
"America/Anguilla" => { :utc_offset => "-04:00",	:utc_offset_dst => "-04:00" },
"America/Antigua" => { :utc_offset => "-04:00",	:utc_offset_dst => "-04:00" },
"America/Araguaina" => { :utc_offset => "-03:00",	:utc_offset_dst => "-03:00" },
"America/Argentina/Buenos_Aires" => { :utc_offset => "-03:00",	:utc_offset_dst => "-03:00" },
"America/Argentina/Catamarca" => { :utc_offset => "-03:00",	:utc_offset_dst => "-03:00" },
"America/Argentina/ComodRivadavia" => { :utc_offset => "-03:00",	:utc_offset_dst => "-03:00" },
"America/Argentina/Cordoba" => { :utc_offset => "-03:00",	:utc_offset_dst => "-03:00" },
"America/Argentina/Jujuy" => { :utc_offset => "-03:00",	:utc_offset_dst => "-03:00" },
"America/Argentina/La_Rioja" => { :utc_offset => "-03:00",	:utc_offset_dst => "-03:00" },
"America/Argentina/Mendoza" => { :utc_offset => "-03:00",	:utc_offset_dst => "-03:00" },
"America/Argentina/Rio_Gallegos" => { :utc_offset => "-03:00",	:utc_offset_dst => "-03:00" },
"America/Argentina/Salta" => { :utc_offset => "-03:00",	:utc_offset_dst => "-03:00" },
"America/Argentina/San_Juan" => { :utc_offset => "-03:00",	:utc_offset_dst => "-03:00" },
"America/Argentina/San_Luis" => { :utc_offset => "-03:00",	:utc_offset_dst => "-03:00" },
"America/Argentina/Tucuman" => { :utc_offset => "-03:00",	:utc_offset_dst => "-03:00" },
"America/Argentina/Ushuaia" => { :utc_offset => "-03:00",	:utc_offset_dst => "-03:00" },
"America/Aruba" => { :utc_offset => "-04:00",	:utc_offset_dst => "-04:00" },
"America/Asuncion" => { :utc_offset => "-04:00",	:utc_offset_dst => "-03:00" },
"America/Atikokan" => { :utc_offset => "-05:00",	:utc_offset_dst => "-05:00" },
"America/Atka" => { :utc_offset => "-10:00",	:utc_offset_dst => "-09:00" },
"America/Bahia" => { :utc_offset => "-03:00",	:utc_offset_dst => "-03:00" },
"America/Bahia_Banderas" => { :utc_offset => "-06:00",	:utc_offset_dst => "-05:00" },
"America/Barbados" => { :utc_offset => "-04:00",	:utc_offset_dst => "-04:00" },
"America/Belem" => { :utc_offset => "-03:00",	:utc_offset_dst => "-03:00" },
"America/Belize" => { :utc_offset => "-06:00",	:utc_offset_dst => "-06:00" },
"America/Blanc-Sablon" => { :utc_offset => "-04:00",	:utc_offset_dst => "-04:00" },
"America/Boa_Vista" => { :utc_offset => "-04:00",	:utc_offset_dst => "-04:00" },
"America/Bogota" => { :utc_offset => "-05:00",	:utc_offset_dst => "-05:00" },
"America/Boise" => { :utc_offset => "-07:00",	:utc_offset_dst => "-06:00" },
"America/Buenos_Aires" => { :utc_offset => "-03:00",	:utc_offset_dst => "-03:00" },
"America/Cambridge_Bay" => { :utc_offset => "-07:00",	:utc_offset_dst => "-06:00" },
"America/Campo_Grande" => { :utc_offset => "-04:00",	:utc_offset_dst => "-03:00" },
"America/Cancun" => { :utc_offset => "-05:00",	:utc_offset_dst => "-05:00" },
"America/Caracas" => { :utc_offset => "-04:00",	:utc_offset_dst => "-04:00" },
"America/Catamarca" => { :utc_offset => "-03:00",	:utc_offset_dst => "-03:00" },
"America/Cayenne" => { :utc_offset => "-03:00",	:utc_offset_dst => "-03:00" },
"America/Cayman" => { :utc_offset => "-05:00",	:utc_offset_dst => "-05:00" },
"America/Chicago" => { :utc_offset => "-06:00",	:utc_offset_dst => "-05:00" },
"America/Chihuahua" => { :utc_offset => "-07:00",	:utc_offset_dst => "-06:00" },
"America/Coral_Harbour" => { :utc_offset => "-05:00",	:utc_offset_dst => "-05:00" },
"America/Cordoba" => { :utc_offset => "-03:00",	:utc_offset_dst => "-03:00" },
"America/Costa_Rica" => { :utc_offset => "-06:00",	:utc_offset_dst => "-06:00" },
"America/Creston" => { :utc_offset => "-07:00",	:utc_offset_dst => "-07:00" },
"America/Cuiaba" => { :utc_offset => "-04:00",	:utc_offset_dst => "-03:00" },
"America/Curacao" => { :utc_offset => "-04:00",	:utc_offset_dst => "-04:00" },
"America/Danmarkshavn" => { :utc_offset => "+00:00",	:utc_offset_dst => "+00:00" },
"America/Dawson" => { :utc_offset => "-08:00",	:utc_offset_dst => "-07:00" },
"America/Dawson_Creek" => { :utc_offset => "-07:00",	:utc_offset_dst => "-07:00" },
"America/Denver" => { :utc_offset => "-07:00",	:utc_offset_dst => "-06:00" },
"America/Detroit" => { :utc_offset => "-05:00",	:utc_offset_dst => "-04:00" },
"America/Dominica" => { :utc_offset => "-04:00",	:utc_offset_dst => "-04:00" },
"America/Edmonton" => { :utc_offset => "-07:00",	:utc_offset_dst => "-06:00" },
"America/Eirunepe" => { :utc_offset => "-05:00",	:utc_offset_dst => "-05:00" },
"America/El_Salvador" => { :utc_offset => "-06:00",	:utc_offset_dst => "-06:00" },
"America/Ensenada" => { :utc_offset => "-08:00",	:utc_offset_dst => "-07:00" },
"America/Fort_Nelson" => { :utc_offset => "-07:00",	:utc_offset_dst => "-07:00" },
"America/Fort_Wayne" => { :utc_offset => "-05:00",	:utc_offset_dst => "-04:00" },
"America/Fortaleza" => { :utc_offset => "-03:00",	:utc_offset_dst => "-03:00" },
"America/Glace_Bay" => { :utc_offset => "-04:00",	:utc_offset_dst => "-03:00" },
"America/Godthab" => { :utc_offset => "-03:00",	:utc_offset_dst => "-02:00" },
"America/Goose_Bay" => { :utc_offset => "-04:00",	:utc_offset_dst => "-03:00" },
"America/Grand_Turk" => { :utc_offset => "-04:00",	:utc_offset_dst => "-04:00" },
"America/Grenada" => { :utc_offset => "-04:00",	:utc_offset_dst => "-04:00" },
"America/Guadeloupe" => { :utc_offset => "-04:00",	:utc_offset_dst => "-04:00" },
"America/Guatemala" => { :utc_offset => "-06:00",	:utc_offset_dst => "-06:00" },
"America/Guayaquil" => { :utc_offset => "-05:00",	:utc_offset_dst => "-05:00" },
"America/Guyana" => { :utc_offset => "-04:00",	:utc_offset_dst => "-04:00" },
"America/Halifax" => { :utc_offset => "-04:00",	:utc_offset_dst => "-03:00" },
"America/Havana" => { :utc_offset => "-05:00",	:utc_offset_dst => "-04:00" },
"America/Hermosillo" => { :utc_offset => "-07:00",	:utc_offset_dst => "-07:00" },
"America/Indiana/Indianapolis" => { :utc_offset => "-05:00",	:utc_offset_dst => "-04:00" },
"America/Indiana/Knox" => { :utc_offset => "-06:00",	:utc_offset_dst => "-05:00" },
"America/Indiana/Marengo" => { :utc_offset => "-05:00",	:utc_offset_dst => "-04:00" },
"America/Indiana/Petersburg" => { :utc_offset => "-05:00",	:utc_offset_dst => "-04:00" },
"America/Indiana/Tell_City" => { :utc_offset => "-06:00",	:utc_offset_dst => "-05:00" },
"America/Indiana/Vevay" => { :utc_offset => "-05:00",	:utc_offset_dst => "-04:00" },
"America/Indiana/Vincennes" => { :utc_offset => "-05:00",	:utc_offset_dst => "-04:00" },
"America/Indiana/Winamac" => { :utc_offset => "-05:00",	:utc_offset_dst => "-04:00" },
"America/Indianapolis" => { :utc_offset => "-05:00",	:utc_offset_dst => "-04:00" },
"America/Inuvik" => { :utc_offset => "-07:00",	:utc_offset_dst => "-06:00" },
"America/Iqaluit" => { :utc_offset => "-05:00",	:utc_offset_dst => "-04:00" },
"America/Jamaica" => { :utc_offset => "-05:00",	:utc_offset_dst => "-05:00" },
"America/Jujuy" => { :utc_offset => "-03:00",	:utc_offset_dst => "-03:00" },
"America/Juneau" => { :utc_offset => "-09:00",	:utc_offset_dst => "-08:00" },
"America/Kentucky/Louisville" => { :utc_offset => "-05:00",	:utc_offset_dst => "-04:00" },
"America/Kentucky/Monticello" => { :utc_offset => "-05:00",	:utc_offset_dst => "-04:00" },
"America/Knox_IN" => { :utc_offset => "-06:00",	:utc_offset_dst => "-05:00" },
"America/Kralendijk" => { :utc_offset => "-04:00",	:utc_offset_dst => "-04:00" },
"America/La_Paz" => { :utc_offset => "-04:00",	:utc_offset_dst => "-04:00" },
"America/Lima" => { :utc_offset => "-05:00",	:utc_offset_dst => "-05:00" },
"America/Los_Angeles" => { :utc_offset => "-08:00",	:utc_offset_dst => "-07:00" },
"America/Louisville" => { :utc_offset => "-05:00",	:utc_offset_dst => "-04:00" },
"America/Lower_Princes" => { :utc_offset => "-04:00",	:utc_offset_dst => "-04:00" },
"America/Maceio" => { :utc_offset => "-03:00",	:utc_offset_dst => "-03:00" },
"America/Managua" => { :utc_offset => "-06:00",	:utc_offset_dst => "-06:00" },
"America/Manaus" => { :utc_offset => "-04:00",	:utc_offset_dst => "-04:00" },
"America/Marigot" => { :utc_offset => "-04:00",	:utc_offset_dst => "-04:00" },
"America/Martinique" => { :utc_offset => "-04:00",	:utc_offset_dst => "-04:00" },
"America/Matamoros" => { :utc_offset => "-06:00",	:utc_offset_dst => "-05:00" },
"America/Mazatlan" => { :utc_offset => "-07:00",	:utc_offset_dst => "-06:00" },
"America/Mendoza" => { :utc_offset => "-03:00",	:utc_offset_dst => "-03:00" },
"America/Menominee" => { :utc_offset => "-06:00",	:utc_offset_dst => "-05:00" },
"America/Merida" => { :utc_offset => "-06:00",	:utc_offset_dst => "-05:00" },
"America/Metlakatla" => { :utc_offset => "-09:00",	:utc_offset_dst => "-08:00" },
"America/Mexico_City" => { :utc_offset => "-06:00",	:utc_offset_dst => "-05:00" },
"America/Miquelon" => { :utc_offset => "-03:00",	:utc_offset_dst => "-02:00" },
"America/Moncton" => { :utc_offset => "-04:00",	:utc_offset_dst => "-03:00" },
"America/Monterrey" => { :utc_offset => "-06:00",	:utc_offset_dst => "-05:00" },
"America/Montevideo" => { :utc_offset => "-03:00",	:utc_offset_dst => "-03:00" },
"America/Montreal" => { :utc_offset => "-05:00",	:utc_offset_dst => "-04:00" },
"America/Montserrat" => { :utc_offset => "-04:00",	:utc_offset_dst => "-04:00" },
"America/Nassau" => { :utc_offset => "-05:00",	:utc_offset_dst => "-04:00" },
"America/New_York" => { :utc_offset => "-05:00",	:utc_offset_dst => "-04:00" },
"America/Nipigon" => { :utc_offset => "-05:00",	:utc_offset_dst => "-04:00" },
"America/Nome" => { :utc_offset => "-09:00",	:utc_offset_dst => "-08:00" },
"America/Noronha" => { :utc_offset => "-02:00",	:utc_offset_dst => "-02:00" },
"America/North_Dakota/Beulah" => { :utc_offset => "-06:00",	:utc_offset_dst => "-05:00" },
"America/North_Dakota/Center" => { :utc_offset => "-06:00",	:utc_offset_dst => "-05:00" },
"America/North_Dakota/New_Salem" => { :utc_offset => "-06:00",	:utc_offset_dst => "-05:00" },
"America/Ojinaga" => { :utc_offset => "-07:00",	:utc_offset_dst => "-06:00" },
"America/Panama" => { :utc_offset => "-05:00",	:utc_offset_dst => "-05:00" },
"America/Pangnirtung" => { :utc_offset => "-05:00",	:utc_offset_dst => "-04:00" },
"America/Paramaribo" => { :utc_offset => "-03:00",	:utc_offset_dst => "-03:00" },
"America/Phoenix" => { :utc_offset => "-07:00",	:utc_offset_dst => "-07:00" },
"America/Port_of_Spain" => { :utc_offset => "-04:00",	:utc_offset_dst => "-04:00" },
"America/Port-au-Prince" => { :utc_offset => "-05:00",	:utc_offset_dst => "-05:00" },
"America/Porto_Acre" => { :utc_offset => "-05:00",	:utc_offset_dst => "-05:00" },
"America/Porto_Velho" => { :utc_offset => "-04:00",	:utc_offset_dst => "-04:00" },
"America/Puerto_Rico" => { :utc_offset => "-04:00",	:utc_offset_dst => "-04:00" },
"America/Rainy_River" => { :utc_offset => "-06:00",	:utc_offset_dst => "-05:00" },
"America/Rankin_Inlet" => { :utc_offset => "-06:00",	:utc_offset_dst => "-05:00" },
"America/Recife" => { :utc_offset => "-03:00",	:utc_offset_dst => "-03:00" },
"America/Regina" => { :utc_offset => "-06:00",	:utc_offset_dst => "-06:00" },
"America/Resolute" => { :utc_offset => "-06:00",	:utc_offset_dst => "-05:00" },
"America/Rio_Branco" => { :utc_offset => "-05:00",	:utc_offset_dst => "-05:00" },
"America/Rosario" => { :utc_offset => "-03:00",	:utc_offset_dst => "-03:00" },
"America/Santa_Isabel" => { :utc_offset => "-08:00",	:utc_offset_dst => "-07:00" },
"America/Santarem" => { :utc_offset => "-03:00",	:utc_offset_dst => "-03:00" },
"America/Santiago" => { :utc_offset => "-04:00",	:utc_offset_dst => "-03:00" },
"America/Santo_Domingo" => { :utc_offset => "-04:00",	:utc_offset_dst => "-04:00" },
"America/Sao_Paulo" => { :utc_offset => "-03:00",	:utc_offset_dst => "-02:00" },
"America/Scoresbysund" => { :utc_offset => "-01:00",	:utc_offset_dst => "+00:00" },
"America/Shiprock" => { :utc_offset => "-07:00",	:utc_offset_dst => "-06:00" },
"America/Sitka" => { :utc_offset => "-09:00",	:utc_offset_dst => "-08:00" },
"America/St_Barthelemy" => { :utc_offset => "-04:00",	:utc_offset_dst => "-04:00" },
"America/St_Johns" => { :utc_offset => "-03:30", :utc_offset_dst => "-02:30" },
"America/St_Kitts" => { :utc_offset => "-04:00",	:utc_offset_dst => "-04:00" },
"America/St_Lucia" => { :utc_offset => "-04:00",	:utc_offset_dst => "-04:00" },
"America/St_Thomas" => { :utc_offset => "-04:00",	:utc_offset_dst => "-04:00" },
"America/St_Vincent" => { :utc_offset => "-04:00",	:utc_offset_dst => "-04:00" },
"America/Swift_Current" => { :utc_offset => "-06:00",	:utc_offset_dst => "-06:00" },
"America/Tegucigalpa" => { :utc_offset => "-06:00",	:utc_offset_dst => "-06:00" },
"America/Thule" => { :utc_offset => "-04:00",	:utc_offset_dst => "-03:00" },
"America/Thunder_Bay" => { :utc_offset => "-05:00",	:utc_offset_dst => "-04:00" },
"America/Tijuana" => { :utc_offset => "-08:00",	:utc_offset_dst => "-07:00" },
"America/Toronto" => { :utc_offset => "-05:00",	:utc_offset_dst => "-04:00" },
"America/Tortola" => { :utc_offset => "-04:00",	:utc_offset_dst => "-04:00" },
"America/Vancouver" => { :utc_offset => "-08:00",	:utc_offset_dst => "-07:00" },
"America/Virgin" => { :utc_offset => "-04:00",	:utc_offset_dst => "-04:00" },
"America/Whitehorse" => { :utc_offset => "-08:00",	:utc_offset_dst => "-07:00" },
"America/Winnipeg" => { :utc_offset => "-06:00",	:utc_offset_dst => "-05:00" },
"America/Yakutat" => { :utc_offset => "-09:00",	:utc_offset_dst => "-08:00" },
"America/Yellowknife" => { :utc_offset => "-07:00",	:utc_offset_dst => "-06:00" },
"Antarctica/Casey" => { :utc_offset => "+08:00",	:utc_offset_dst => "+08:00" },
"Antarctica/Davis" => { :utc_offset => "+07:00",	:utc_offset_dst => "+07:00" },
"Antarctica/DumontDUrville" => { :utc_offset => "+10:00",	:utc_offset_dst => "+10:00" },
"Antarctica/Macquarie" => { :utc_offset => "+11:00",	:utc_offset_dst => "+11:00" },
"Antarctica/Mawson" => { :utc_offset => "+05:00",	:utc_offset_dst => "+05:00" },
"Antarctica/McMurdo" => { :utc_offset => "+12:00",	:utc_offset_dst => "+13:00" },
"Antarctica/Palmer" => { :utc_offset => "-04:00",	:utc_offset_dst => "-03:00" },
"Antarctica/Rothera" => { :utc_offset => "-03:00",	:utc_offset_dst => "-03:00" },
"Antarctica/South_Pole" => { :utc_offset => "+12:00",	:utc_offset_dst => "+13:00" },
"Antarctica/Syowa" => { :utc_offset => "+03:00",	:utc_offset_dst => "+03:00" },
"Antarctica/Troll" => { :utc_offset => "+00:00",	:utc_offset_dst => "+02:00" },
"Antarctica/Vostok" => { :utc_offset => "+06:00",	:utc_offset_dst => "+06:00" },
"Arctic/Longyearbyen" => { :utc_offset => "+01:00",	:utc_offset_dst => "+02:00" },
"Asia/Aden" => { :utc_offset => "+03:00",	:utc_offset_dst => "+03:00" },
"Asia/Almaty" => { :utc_offset => "+06:00",	:utc_offset_dst => "+06:00" },
"Asia/Amman" => { :utc_offset => "+02:00",	:utc_offset_dst => "+03:00" },
"Asia/Anadyr" => { :utc_offset => "+12:00",	:utc_offset_dst => "+12:00" },
"Asia/Aqtau" => { :utc_offset => "+05:00",	:utc_offset_dst => "+05:00" },
"Asia/Aqtobe" => { :utc_offset => "+05:00",	:utc_offset_dst => "+05:00" },
"Asia/Ashgabat" => { :utc_offset => "+05:00",	:utc_offset_dst => "+05:00" },
"Asia/Ashkhabad" => { :utc_offset => "+05:00",	:utc_offset_dst => "+05:00" },
"Asia/Baghdad" => { :utc_offset => "+03:00",	:utc_offset_dst => "+03:00" },
"Asia/Bahrain" => { :utc_offset => "+03:00",	:utc_offset_dst => "+03:00" },
"Asia/Baku" => { :utc_offset => "+04:00",	:utc_offset_dst => "+04:00" },
"Asia/Bangkok" => { :utc_offset => "+07:00",	:utc_offset_dst => "+07:00" },
"Asia/Barnaul" => { :utc_offset => "+07:00",	:utc_offset_dst => "+07:00" },
"Asia/Beirut" => { :utc_offset => "+02:00",	:utc_offset_dst => "+03:00" },
"Asia/Bishkek" => { :utc_offset => "+06:00",	:utc_offset_dst => "+06:00" },
"Asia/Brunei" => { :utc_offset => "+08:00",	:utc_offset_dst => "+08:00" },
"Asia/Calcutta" => { :utc_offset => "+05:30",	:utc_offset_dst => "+05:30" },
"Asia/Chita" => { :utc_offset => "+09:00",	:utc_offset_dst => "+09:00" },
"Asia/Choibalsan" => { :utc_offset => "+08:00",	:utc_offset_dst => "+09:00" },
"Asia/Chongqing" => { :utc_offset => "+08:00",	:utc_offset_dst => "+08:00" },
"Asia/Chungking" => { :utc_offset => "+08:00",	:utc_offset_dst => "+08:00" },
"Asia/Colombo" => { :utc_offset => "+05:30",	:utc_offset_dst => "+05:30" },
"Asia/Dacca" => { :utc_offset => "+06:00",	:utc_offset_dst => "+06:00" },
"Asia/Damascus" => { :utc_offset => "+02:00",	:utc_offset_dst => "+03:00" },
"Asia/Dhaka" => { :utc_offset => "+06:00",	:utc_offset_dst => "+06:00" },
"Asia/Dili" => { :utc_offset => "+09:00",	:utc_offset_dst => "+09:00" },
"Asia/Dubai" => { :utc_offset => "+04:00",	:utc_offset_dst => "+04:00" },
"Asia/Dushanbe" => { :utc_offset => "+05:00",	:utc_offset_dst => "+05:00" },
"Asia/Gaza" => { :utc_offset => "+02:00",	:utc_offset_dst => "+03:00" },
"Asia/Harbin" => { :utc_offset => "+08:00",	:utc_offset_dst => "+08:00" },
"Asia/Hebron" => { :utc_offset => "+02:00",	:utc_offset_dst => "+03:00" },
"Asia/Ho_Chi_Minh" => { :utc_offset => "+07:00",	:utc_offset_dst => "+07:00" },
"Asia/Hong_Kong" => { :utc_offset => "+08:00",	:utc_offset_dst => "+08:00" },
"Asia/Hovd" => { :utc_offset => "+07:00",	:utc_offset_dst => "+08:00" },
"Asia/Irkutsk" => { :utc_offset => "+08:00",	:utc_offset_dst => "+08:00" },
"Asia/Istanbul" => { :utc_offset => "+02:00",	:utc_offset_dst => "+03:00" },
"Asia/Jakarta" => { :utc_offset => "+07:00",	:utc_offset_dst => "+07:00" },
"Asia/Jayapura" => { :utc_offset => "+09:00",	:utc_offset_dst => "+09:00" },
"Asia/Jerusalem" => { :utc_offset => "+02:00",	:utc_offset_dst => "+03:00" },
"Asia/Kabul" => { :utc_offset => "+04:30",	:utc_offset_dst => "+04:30" },
"Asia/Kamchatka" => { :utc_offset => "+12:00",	:utc_offset_dst => "+12:00" },
"Asia/Karachi" => { :utc_offset => "+05:00",	:utc_offset_dst => "+05:00" },
"Asia/Kashgar" => { :utc_offset => "+06:00",	:utc_offset_dst => "+06:00" },
"Asia/Kathmandu" => { :utc_offset => "+05:45",	:utc_offset_dst => "+05:45" },
"Asia/Katmandu" => { :utc_offset => "+05:45",	:utc_offset_dst => "+05:45" },
"Asia/Khandyga" => { :utc_offset => "+09:00",	:utc_offset_dst => "+09:00" },
"Asia/Kolkata" => { :utc_offset => "+05:30",	:utc_offset_dst => "+05:30" },
"Asia/Krasnoyarsk" => { :utc_offset => "+07:00",	:utc_offset_dst => "+07:00" },
"Asia/Kuala_Lumpur" => { :utc_offset => "+08:00",	:utc_offset_dst => "+08:00" },
"Asia/Kuching" => { :utc_offset => "+08:00",	:utc_offset_dst => "+08:00" },
"Asia/Kuwait" => { :utc_offset => "+03:00",	:utc_offset_dst => "+03:00" },
"Asia/Macao" => { :utc_offset => "+08:00",	:utc_offset_dst => "+08:00" },
"Asia/Macau" => { :utc_offset => "+08:00",	:utc_offset_dst => "+08:00" },
"Asia/Magadan" => { :utc_offset => "+11:00",	:utc_offset_dst => "+11:00" },
"Asia/Makassar" => { :utc_offset => "+08:00",	:utc_offset_dst => "+08:00" },
"Asia/Manila" => { :utc_offset => "+08:00",	:utc_offset_dst => "+08:00" },
"Asia/Muscat" => { :utc_offset => "+04:00",	:utc_offset_dst => "+04:00" },
"Asia/Nicosia" => { :utc_offset => "+02:00",	:utc_offset_dst => "+03:00" },
"Asia/Novokuznetsk" => { :utc_offset => "+07:00",	:utc_offset_dst => "+07:00" },
"Asia/Novosibirsk" => { :utc_offset => "+06:00",	:utc_offset_dst => "+06:00" },
"Asia/Omsk" => { :utc_offset => "+06:00",	:utc_offset_dst => "+06:00" },
"Asia/Oral" => { :utc_offset => "+05:00",	:utc_offset_dst => "+05:00" },
"Asia/Phnom_Penh" => { :utc_offset => "+07:00",	:utc_offset_dst => "+07:00" },
"Asia/Pontianak" => { :utc_offset => "+07:00",	:utc_offset_dst => "+07:00" },
"Asia/Pyongyang" => { :utc_offset => "+08:30",	:utc_offset_dst => "+08:30" },
"Asia/Qatar" => { :utc_offset => "+03:00",	:utc_offset_dst => "+03:00" },
"Asia/Qyzylorda" => { :utc_offset => "+06:00",	:utc_offset_dst => "+06:00" },
"Asia/Rangoon" => { :utc_offset => "+06:30",	:utc_offset_dst => "+06:30" },
"Asia/Riyadh" => { :utc_offset => "+03:00",	:utc_offset_dst => "+03:00" },
"Asia/Saigon" => { :utc_offset => "+07:00",	:utc_offset_dst => "+07:00" },
"Asia/Sakhalin" => { :utc_offset => "+11:00",	:utc_offset_dst => "+11:00" },
"Asia/Samarkand" => { :utc_offset => "+05:00",	:utc_offset_dst => "+05:00" },
"Asia/Seoul" => { :utc_offset => "+09:00",	:utc_offset_dst => "+09:00" },
"Asia/Shanghai" => { :utc_offset => "+08:00",	:utc_offset_dst => "+08:00" },
"Asia/Singapore" => { :utc_offset => "+08:00",	:utc_offset_dst => "+08:00" },
"Asia/Srednekolymsk" => { :utc_offset => "+11:00",	:utc_offset_dst => "+11:00" },
"Asia/Taipei" => { :utc_offset => "+08:00",	:utc_offset_dst => "+08:00" },
"Asia/Tashkent" => { :utc_offset => "+05:00",	:utc_offset_dst => "+05:00" },
"Asia/Tbilisi" => { :utc_offset => "+04:00",	:utc_offset_dst => "+04:00" },
"Asia/Tehran" => { :utc_offset => "+03:30",	:utc_offset_dst => "+04:30" },
"Asia/Tel_Aviv" => { :utc_offset => "+02:00",	:utc_offset_dst => "+03:00" },
"Asia/Thimbu" => { :utc_offset => "+06:00",	:utc_offset_dst => "+06:00" },
"Asia/Thimphu" => { :utc_offset => "+06:00",	:utc_offset_dst => "+06:00" },
"Asia/Tokyo" => { :utc_offset => "+09:00",	:utc_offset_dst => "+09:00" },
"Asia/Tomsk" => { :utc_offset => "+07:00",	:utc_offset_dst => "+07:00" },
"Asia/Ujung_Pandang" => { :utc_offset => "+08:00",	:utc_offset_dst => "+08:00" },
"Asia/Ulaanbaatar" => { :utc_offset => "+08:00",	:utc_offset_dst => "+09:00" },
"Asia/Ulan_Bator" => { :utc_offset => "+08:00",	:utc_offset_dst => "+09:00" },
"Asia/Urumqi" => { :utc_offset => "+06:00",	:utc_offset_dst => "+06:00" },
"Asia/Ust-Nera" => { :utc_offset => "+10:00",	:utc_offset_dst => "+10:00" },
"Asia/Vientiane" => { :utc_offset => "+07:00",	:utc_offset_dst => "+07:00" },
"Asia/Vladivostok" => { :utc_offset => "+10:00",	:utc_offset_dst => "+10:00" },
"Asia/Yakutsk" => { :utc_offset => "+09:00",	:utc_offset_dst => "+09:00" },
"Asia/Yekaterinburg" => { :utc_offset => "+05:00",	:utc_offset_dst => "+05:00" },
"Asia/Yerevan" => { :utc_offset => "+04:00",	:utc_offset_dst => "+04:00" },
"Atlantic/Azores" => { :utc_offset => "-01:00",	:utc_offset_dst => "+00:00" },
"Atlantic/Bermuda" => { :utc_offset => "-04:00",	:utc_offset_dst => "-03:00" },
"Atlantic/Canary" => { :utc_offset => "+00:00",	:utc_offset_dst => "+01:00" },
"Atlantic/Cape_Verde" => { :utc_offset => "-01:00",	:utc_offset_dst => "-01:00" },
"Atlantic/Faeroe" => { :utc_offset => "+00:00",	:utc_offset_dst => "+01:00" },
"Atlantic/Faroe" => { :utc_offset => "+00:00",	:utc_offset_dst => "+01:00" },
"Atlantic/Jan_Mayen" => { :utc_offset => "+01:00",	:utc_offset_dst => "+02:00" },
"Atlantic/Madeira" => { :utc_offset => "+00:00",	:utc_offset_dst => "+01:00" },
"Atlantic/Reykjavik" => { :utc_offset => "+00:00",	:utc_offset_dst => "+00:00" },
"Atlantic/South_Georgia" => { :utc_offset => "-02:00",	:utc_offset_dst => "-02:00" },
"Atlantic/St_Helena" => { :utc_offset => "+00:00",	:utc_offset_dst => "+00:00" },
"Atlantic/Stanley" => { :utc_offset => "-03:00",	:utc_offset_dst => "-03:00" },
"Australia/ACT" => { :utc_offset => "+10:00",	:utc_offset_dst => "+11:00" },
"Australia/Adelaide" => { :utc_offset => "+09:30",	:utc_offset_dst => "+10:30" },
"Australia/Brisbane" => { :utc_offset => "+10:00",	:utc_offset_dst => "+10:00" },
"Australia/Broken_Hill" => { :utc_offset => "+09:30",	:utc_offset_dst => "+10:30" },
"Australia/Canberra" => { :utc_offset => "+10:00",	:utc_offset_dst => "+11:00" },
"Australia/Currie" => { :utc_offset => "+10:00",	:utc_offset_dst => "+11:00" },
"Australia/Darwin" => { :utc_offset => "+09:30",	:utc_offset_dst => "+09:30" },
"Australia/Eucla" => { :utc_offset => "+08:45",	:utc_offset_dst => "+08:45" },
"Australia/Hobart" => { :utc_offset => "+10:00",	:utc_offset_dst => "+11:00" },
"Australia/LHI" => { :utc_offset => "+10:30",	:utc_offset_dst => "+11:00" },
"Australia/Lindeman" => { :utc_offset => "+10:00",	:utc_offset_dst => "+10:00" },
"Australia/Lord_Howe" => { :utc_offset => "+10:30",	:utc_offset_dst => "+11:00" },
"Australia/Melbourne" => { :utc_offset => "+10:00",	:utc_offset_dst => "+11:00" },
"Australia/North" => { :utc_offset => "+09:30",	:utc_offset_dst => "+09:30" },
"Australia/NSW" => { :utc_offset => "+10:00",	:utc_offset_dst => "+11:00" },
"Australia/Perth" => { :utc_offset => "+08:00",	:utc_offset_dst => "+08:00" },
"Australia/Queensland" => { :utc_offset => "+10:00",	:utc_offset_dst => "+10:00" },
"Australia/South" => { :utc_offset => "+09:30",	:utc_offset_dst => "+10:30" },
"Australia/Sydney" => { :utc_offset => "+10:00",	:utc_offset_dst => "+11:00" },
"Australia/Tasmania" => { :utc_offset => "+10:00",	:utc_offset_dst => "+11:00" },
"Australia/Victoria" => { :utc_offset => "+10:00",	:utc_offset_dst => "+11:00" },
"Australia/West" => { :utc_offset => "+08:00",	:utc_offset_dst => "+08:00" },
"Australia/Yancowinna" => { :utc_offset => "+09:30",	:utc_offset_dst => "+10:30" },
"Brazil/Acre" => { :utc_offset => "-05:00",	:utc_offset_dst => "-05:00" },
"Brazil/DeNoronha" => { :utc_offset => "-02:00",	:utc_offset_dst => "-02:00" },
"Brazil/East" => { :utc_offset => "-03:00",	:utc_offset_dst => "-02:00" },
"Brazil/West" => { :utc_offset => "-04:00",	:utc_offset_dst => "-04:00" },
"Canada/Atlantic" => { :utc_offset => "-04:00",	:utc_offset_dst => "-03:00" },
"Canada/Central" => { :utc_offset => "-06:00",	:utc_offset_dst => "-05:00" },
"Canada/Eastern" => { :utc_offset => "-05:00",	:utc_offset_dst => "-04:00" },
"Canada/East-Saskatchewan" => { :utc_offset => "-06:00",	:utc_offset_dst => "-06:00" },
"Canada/Mountain" => { :utc_offset => "-07:00",	:utc_offset_dst => "-06:00" },
"Canada/Newfoundland" => { :utc_offset => "-03:30", :utc_offset_dst => "-02:30" },
"Canada/Pacific" => { :utc_offset => "-08:00",	:utc_offset_dst => "-07:00" },
"Canada/Saskatchewan" => { :utc_offset => "-06:00",	:utc_offset_dst => "-06:00" },
"Canada/Yukon" => { :utc_offset => "-08:00",	:utc_offset_dst => "-07:00" },
"CET" => { :utc_offset => "+01:00",	:utc_offset_dst => "+02:00" },
"Chile/Continental" => { :utc_offset => "-04:00",	:utc_offset_dst => "-03:00" },
"Chile/EasterIsland" => { :utc_offset => "-06:00",	:utc_offset_dst => "-05:00" },
"CST6CDT" => { :utc_offset => "-06:00",	:utc_offset_dst => "-05:00" },
"Cuba" => { :utc_offset => "-05:00",	:utc_offset_dst => "-04:00" },
"EET" => { :utc_offset => "+02:00",	:utc_offset_dst => "+03:00" },
"Egypt" => { :utc_offset => "+02:00",	:utc_offset_dst => "+02:00" },
"Eire" => { :utc_offset => "+00:00",	:utc_offset_dst => "+01:00" },
"EST" => { :utc_offset => "-05:00",	:utc_offset_dst => "-05:00" },
"EST5EDT" => { :utc_offset => "-05:00",	:utc_offset_dst => "-04:00" },
"Etc/GMT" => { :utc_offset => "+00:00",	:utc_offset_dst => "+00:00" },
"Etc/GMT+0" => { :utc_offset => "+00:00",	:utc_offset_dst => "+00:00" },
"Etc/GMT+1" => { :utc_offset => "-01:00",	:utc_offset_dst => "-01:00" },
"Etc/GMT+10" => { :utc_offset => "-10:00",	:utc_offset_dst => "-10:00" },
"Etc/GMT+11" => { :utc_offset => "-11:00",	:utc_offset_dst => "-11:00" },
"Etc/GMT+12" => { :utc_offset => "-12:00",	:utc_offset_dst => "-12:00" },
"Etc/GMT+2" => { :utc_offset => "-02:00",	:utc_offset_dst => "-02:00" },
"Etc/GMT+3" => { :utc_offset => "-03:00",	:utc_offset_dst => "-03:00" },
"Etc/GMT+4" => { :utc_offset => "-04:00",	:utc_offset_dst => "-04:00" },
"Etc/GMT+5" => { :utc_offset => "-05:00",	:utc_offset_dst => "-05:00" },
"Etc/GMT+6" => { :utc_offset => "-06:00",	:utc_offset_dst => "-06:00" },
"Etc/GMT+7" => { :utc_offset => "-07:00",	:utc_offset_dst => "-07:00" },
"Etc/GMT+8" => { :utc_offset => "-08:00",	:utc_offset_dst => "-08:00" },
"Etc/GMT+9" => { :utc_offset => "-09:00",	:utc_offset_dst => "-09:00" },
"Etc/GMT0" => { :utc_offset => "+00:00",	:utc_offset_dst => "+00:00" },
"Etc/GMT-0" => { :utc_offset => "+00:00",	:utc_offset_dst => "+00:00" },
"Etc/GMT-1" => { :utc_offset => "+01:00",	:utc_offset_dst => "+01:00" },
"Etc/GMT-10" => { :utc_offset => "+10:00",	:utc_offset_dst => "+10:00" },
"Etc/GMT-11" => { :utc_offset => "+11:00",	:utc_offset_dst => "+11:00" },
"Etc/GMT-12" => { :utc_offset => "+12:00",	:utc_offset_dst => "+12:00" },
"Etc/GMT-13" => { :utc_offset => "+13:00",	:utc_offset_dst => "+13:00" },
"Etc/GMT-14" => { :utc_offset => "+14:00",	:utc_offset_dst => "+14:00" },
"Etc/GMT-2" => { :utc_offset => "+02:00",	:utc_offset_dst => "+02:00" },
"Etc/GMT-3" => { :utc_offset => "+03:00",	:utc_offset_dst => "+03:00" },
"Etc/GMT-4" => { :utc_offset => "+04:00",	:utc_offset_dst => "+04:00" },
"Etc/GMT-5" => { :utc_offset => "+05:00",	:utc_offset_dst => "+05:00" },
"Etc/GMT-6" => { :utc_offset => "+06:00",	:utc_offset_dst => "+06:00" },
"Etc/GMT-7" => { :utc_offset => "+07:00",	:utc_offset_dst => "+07:00" },
"Etc/GMT-8" => { :utc_offset => "+08:00",	:utc_offset_dst => "+08:00" },
"Etc/GMT-9" => { :utc_offset => "+09:00",	:utc_offset_dst => "+09:00" },
"Etc/Greenwich" => { :utc_offset => "+00:00",	:utc_offset_dst => "+00:00" },
"Etc/UCT" => { :utc_offset => "+00:00",	:utc_offset_dst => "+00:00" },
"Etc/Universal" => { :utc_offset => "+00:00",	:utc_offset_dst => "+00:00" },
"Etc/UTC" => { :utc_offset => "+00:00",	:utc_offset_dst => "+00:00" },
"Etc/Zulu" => { :utc_offset => "+00:00",	:utc_offset_dst => "+00:00" },
"Europe/Amsterdam" => { :utc_offset => "+01:00",	:utc_offset_dst => "+02:00" },
"Europe/Andorra" => { :utc_offset => "+01:00",	:utc_offset_dst => "+02:00" },
"Europe/Astrakhan" => { :utc_offset => "+04:00",	:utc_offset_dst => "+04:00" },
"Europe/Athens" => { :utc_offset => "+02:00",	:utc_offset_dst => "+03:00" },
"Europe/Belfast" => { :utc_offset => "+00:00",	:utc_offset_dst => "+01:00" },
"Europe/Belgrade" => { :utc_offset => "+01:00",	:utc_offset_dst => "+02:00" },
"Europe/Berlin" => { :utc_offset => "+01:00",	:utc_offset_dst => "+02:00" },
"Europe/Bratislava" => { :utc_offset => "+01:00",	:utc_offset_dst => "+02:00" },
"Europe/Brussels" => { :utc_offset => "+01:00",	:utc_offset_dst => "+02:00" },
"Europe/Bucharest" => { :utc_offset => "+02:00",	:utc_offset_dst => "+03:00" },
"Europe/Budapest" => { :utc_offset => "+01:00",	:utc_offset_dst => "+02:00" },
"Europe/Busingen" => { :utc_offset => "+01:00",	:utc_offset_dst => "+02:00" },
"Europe/Chisinau" => { :utc_offset => "+02:00",	:utc_offset_dst => "+03:00" },
"Europe/Copenhagen" => { :utc_offset => "+01:00",	:utc_offset_dst => "+02:00" },
"Europe/Dublin" => { :utc_offset => "+00:00",	:utc_offset_dst => "+01:00" },
"Europe/Gibraltar" => { :utc_offset => "+01:00",	:utc_offset_dst => "+02:00" },
"Europe/Guernsey" => { :utc_offset => "+00:00",	:utc_offset_dst => "+01:00" },
"Europe/Helsinki" => { :utc_offset => "+02:00",	:utc_offset_dst => "+03:00" },
"Europe/Isle_of_Man" => { :utc_offset => "+00:00",	:utc_offset_dst => "+01:00" },
"Europe/Istanbul" => { :utc_offset => "+02:00",	:utc_offset_dst => "+03:00" },
"Europe/Jersey" => { :utc_offset => "+00:00",	:utc_offset_dst => "+01:00" },
"Europe/Kaliningrad" => { :utc_offset => "+02:00",	:utc_offset_dst => "+02:00" },
"Europe/Kiev" => { :utc_offset => "+02:00",	:utc_offset_dst => "+03:00" },
"Europe/Kirov" => { :utc_offset => "+03:00",	:utc_offset_dst => "+03:00" },
"Europe/Lisbon" => { :utc_offset => "+00:00",	:utc_offset_dst => "+01:00" },
"Europe/Ljubljana" => { :utc_offset => "+01:00",	:utc_offset_dst => "+02:00" },
"Europe/London" => { :utc_offset => "+00:00",	:utc_offset_dst => "+01:00" },
"Europe/Luxembourg" => { :utc_offset => "+01:00",	:utc_offset_dst => "+02:00" },
"Europe/Madrid" => { :utc_offset => "+01:00",	:utc_offset_dst => "+02:00" },
"Europe/Malta" => { :utc_offset => "+01:00",	:utc_offset_dst => "+02:00" },
"Europe/Mariehamn" => { :utc_offset => "+02:00",	:utc_offset_dst => "+03:00" },
"Europe/Minsk" => { :utc_offset => "+03:00",	:utc_offset_dst => "+03:00" },
"Europe/Monaco" => { :utc_offset => "+01:00",	:utc_offset_dst => "+02:00" },
"Europe/Moscow" => { :utc_offset => "+03:00",	:utc_offset_dst => "+03:00" },
"Europe/Nicosia" => { :utc_offset => "+02:00",	:utc_offset_dst => "+03:00" },
"Europe/Oslo" => { :utc_offset => "+01:00",	:utc_offset_dst => "+02:00" },
"Europe/Paris" => { :utc_offset => "+01:00",	:utc_offset_dst => "+02:00" },
"Europe/Podgorica" => { :utc_offset => "+01:00",	:utc_offset_dst => "+02:00" },
"Europe/Prague" => { :utc_offset => "+01:00",	:utc_offset_dst => "+02:00" },
"Europe/Riga" => { :utc_offset => "+02:00",	:utc_offset_dst => "+03:00" },
"Europe/Rome" => { :utc_offset => "+01:00",	:utc_offset_dst => "+02:00" },
"Europe/Samara" => { :utc_offset => "+04:00",	:utc_offset_dst => "+04:00" },
"Europe/San_Marino" => { :utc_offset => "+01:00",	:utc_offset_dst => "+02:00" },
"Europe/Sarajevo" => { :utc_offset => "+01:00",	:utc_offset_dst => "+02:00" },
"Europe/Simferopol" => { :utc_offset => "+03:00",	:utc_offset_dst => "+03:00" },
"Europe/Skopje" => { :utc_offset => "+01:00",	:utc_offset_dst => "+02:00" },
"Europe/Sofia" => { :utc_offset => "+02:00",	:utc_offset_dst => "+03:00" },
"Europe/Stockholm" => { :utc_offset => "+01:00",	:utc_offset_dst => "+02:00" },
"Europe/Tallinn" => { :utc_offset => "+02:00",	:utc_offset_dst => "+03:00" },
"Europe/Tirane" => { :utc_offset => "+01:00",	:utc_offset_dst => "+02:00" },
"Europe/Tiraspol" => { :utc_offset => "+02:00",	:utc_offset_dst => "+03:00" },
"Europe/Ulyanovsk" => { :utc_offset => "+04:00",	:utc_offset_dst => "+04:00" },
"Europe/Uzhgorod" => { :utc_offset => "+02:00",	:utc_offset_dst => "+03:00" },
"Europe/Vaduz" => { :utc_offset => "+01:00",	:utc_offset_dst => "+02:00" },
"Europe/Vatican" => { :utc_offset => "+01:00",	:utc_offset_dst => "+02:00" },
"Europe/Vienna" => { :utc_offset => "+01:00",	:utc_offset_dst => "+02:00" },
"Europe/Vilnius" => { :utc_offset => "+02:00",	:utc_offset_dst => "+03:00" },
"Europe/Volgograd" => { :utc_offset => "+03:00",	:utc_offset_dst => "+03:00" },
"Europe/Warsaw" => { :utc_offset => "+01:00",	:utc_offset_dst => "+02:00" },
"Europe/Zagreb" => { :utc_offset => "+01:00",	:utc_offset_dst => "+02:00" },
"Europe/Zaporozhye" => { :utc_offset => "+02:00",	:utc_offset_dst => "+03:00" },
"Europe/Zurich" => { :utc_offset => "+01:00",	:utc_offset_dst => "+02:00" },
"GB" => { :utc_offset => "+00:00",	:utc_offset_dst => "+01:00" },
"GB-Eire" => { :utc_offset => "+00:00",	:utc_offset_dst => "+01:00" },
"GMT" => { :utc_offset => "+00:00",	:utc_offset_dst => "+00:00" },
"GMT+0" => { :utc_offset => "+00:00",	:utc_offset_dst => "+00:00" },
"GMT0" => { :utc_offset => "+00:00",	:utc_offset_dst => "+00:00" },
"GMT-0" => { :utc_offset => "+00:00",	:utc_offset_dst => "+00:00" },
"Greenwich" => { :utc_offset => "+00:00",	:utc_offset_dst => "+00:00" },
"Hongkong" => { :utc_offset => "+08:00",	:utc_offset_dst => "+08:00" },
"HST" => { :utc_offset => "-10:00",	:utc_offset_dst => "-10:00" },
"Iceland" => { :utc_offset => "+00:00",	:utc_offset_dst => "+00:00" },
"Indian/Antananarivo" => { :utc_offset => "+03:00",	:utc_offset_dst => "+03:00" },
"Indian/Chagos" => { :utc_offset => "+06:00",	:utc_offset_dst => "+06:00" },
"Indian/Christmas" => { :utc_offset => "+07:00",	:utc_offset_dst => "+07:00" },
"Indian/Cocos" => { :utc_offset => "+06:30",	:utc_offset_dst => "+06:30" },
"Indian/Comoro" => { :utc_offset => "+03:00",	:utc_offset_dst => "+03:00" },
"Indian/Kerguelen" => { :utc_offset => "+05:00",	:utc_offset_dst => "+05:00" },
"Indian/Mahe" => { :utc_offset => "+04:00",	:utc_offset_dst => "+04:00" },
"Indian/Maldives" => { :utc_offset => "+05:00",	:utc_offset_dst => "+05:00" },
"Indian/Mauritius" => { :utc_offset => "+04:00",	:utc_offset_dst => "+04:00" },
"Indian/Mayotte" => { :utc_offset => "+03:00",	:utc_offset_dst => "+03:00" },
"Indian/Reunion" => { :utc_offset => "+04:00",	:utc_offset_dst => "+04:00" },
"Iran" => { :utc_offset => "+03:30",	:utc_offset_dst => "+04:30" },
"Israel" => { :utc_offset => "+02:00",	:utc_offset_dst => "+03:00" },
"Jamaica" => { :utc_offset => "-05:00",	:utc_offset_dst => "-05:00" },
"Japan" => { :utc_offset => "+09:00",	:utc_offset_dst => "+09:00" },
"Kwajalein" => { :utc_offset => "+12:00",	:utc_offset_dst => "+12:00" },
"Libya" => { :utc_offset => "+02:00",	:utc_offset_dst => "+02:00" },
"MET" => { :utc_offset => "+01:00",	:utc_offset_dst => "+02:00" },
"Mexico/BajaNorte" => { :utc_offset => "-08:00",	:utc_offset_dst => "-07:00" },
"Mexico/BajaSur" => { :utc_offset => "-07:00",	:utc_offset_dst => "-06:00" },
"Mexico/General" => { :utc_offset => "-06:00",	:utc_offset_dst => "-05:00" },
"MST" => { :utc_offset => "-07:00",	:utc_offset_dst => "-07:00" },
"MST7MDT" => { :utc_offset => "-07:00",	:utc_offset_dst => "-06:00" },
"Navajo" => { :utc_offset => "-07:00",	:utc_offset_dst => "-06:00" },
"NZ" => { :utc_offset => "+12:00",	:utc_offset_dst => "+13:00" },
"NZ-CHAT" => { :utc_offset => "+12:45",	:utc_offset_dst => "+13:45" },
"Pacific/Apia" => { :utc_offset => "+13:00",	:utc_offset_dst => "+14:00" },
"Pacific/Auckland" => { :utc_offset => "+12:00",	:utc_offset_dst => "+13:00" },
"Pacific/Bougainville" => { :utc_offset => "+11:00",	:utc_offset_dst => "+11:00" },
"Pacific/Chatham" => { :utc_offset => "+12:45",	:utc_offset_dst => "+13:45" },
"Pacific/Chuuk" => { :utc_offset => "+10:00",	:utc_offset_dst => "+10:00" },
"Pacific/Easter" => { :utc_offset => "-06:00",	:utc_offset_dst => "-05:00" },
"Pacific/Efate" => { :utc_offset => "+11:00",	:utc_offset_dst => "+11:00" },
"Pacific/Enderbury" => { :utc_offset => "+13:00",	:utc_offset_dst => "+13:00" },
"Pacific/Fakaofo" => { :utc_offset => "+13:00",	:utc_offset_dst => "+13:00" },
"Pacific/Fiji" => { :utc_offset => "+12:00",	:utc_offset_dst => "+13:00" },
"Pacific/Funafuti" => { :utc_offset => "+12:00",	:utc_offset_dst => "+12:00" },
"Pacific/Galapagos" => { :utc_offset => "-06:00",	:utc_offset_dst => "-06:00" },
"Pacific/Gambier" => { :utc_offset => "-09:00",	:utc_offset_dst => "-09:00" },
"Pacific/Guadalcanal" => { :utc_offset => "+11:00",	:utc_offset_dst => "+11:00" },
"Pacific/Guam" => { :utc_offset => "+10:00",	:utc_offset_dst => "+10:00" },
"Pacific/Honolulu" => { :utc_offset => "-10:00",	:utc_offset_dst => "-10:00" },
"Pacific/Johnston" => { :utc_offset => "-10:00",	:utc_offset_dst => "-10:00" },
"Pacific/Kiritimati" => { :utc_offset => "+14:00",	:utc_offset_dst => "+14:00" },
"Pacific/Kosrae" => { :utc_offset => "+11:00",	:utc_offset_dst => "+11:00" },
"Pacific/Kwajalein" => { :utc_offset => "+12:00",	:utc_offset_dst => "+12:00" },
"Pacific/Majuro" => { :utc_offset => "+12:00",	:utc_offset_dst => "+12:00" },
"Pacific/Marquesas" => { :utc_offset => "-09:30", :utc_offset_dst => "-09:30" },
"Pacific/Midway" => { :utc_offset => "-11:00",	:utc_offset_dst => "-11:00" },
"Pacific/Nauru" => { :utc_offset => "+12:00",	:utc_offset_dst => "+12:00" },
"Pacific/Niue" => { :utc_offset => "-11:00",	:utc_offset_dst => "-11:00" },
"Pacific/Norfolk" => { :utc_offset => "+11:00",	:utc_offset_dst => "+11:00" },
"Pacific/Noumea" => { :utc_offset => "+11:00",	:utc_offset_dst => "+11:00" },
"Pacific/Pago_Pago" => { :utc_offset => "-11:00",	:utc_offset_dst => "-11:00" },
"Pacific/Palau" => { :utc_offset => "+09:00",	:utc_offset_dst => "+09:00" },
"Pacific/Pitcairn" => { :utc_offset => "-08:00",	:utc_offset_dst => "-08:00" },
"Pacific/Pohnpei" => { :utc_offset => "+11:00",	:utc_offset_dst => "+11:00" },
"Pacific/Ponape" => { :utc_offset => "+11:00",	:utc_offset_dst => "+11:00" },
"Pacific/Port_Moresby" => { :utc_offset => "+10:00",	:utc_offset_dst => "+10:00" },
"Pacific/Rarotonga" => { :utc_offset => "-10:00",	:utc_offset_dst => "-10:00" },
"Pacific/Saipan" => { :utc_offset => "+10:00",	:utc_offset_dst => "+10:00" },
"Pacific/Samoa" => { :utc_offset => "-11:00",	:utc_offset_dst => "-11:00" },
"Pacific/Tahiti" => { :utc_offset => "-10:00",	:utc_offset_dst => "-10:00" },
"Pacific/Tarawa" => { :utc_offset => "+12:00",	:utc_offset_dst => "+12:00" },
"Pacific/Tongatapu" => { :utc_offset => "+13:00",	:utc_offset_dst => "+13:00" },
"Pacific/Truk" => { :utc_offset => "+10:00",	:utc_offset_dst => "+10:00" },
"Pacific/Wake" => { :utc_offset => "+12:00",	:utc_offset_dst => "+12:00" },
"Pacific/Wallis" => { :utc_offset => "+12:00",	:utc_offset_dst => "+12:00" },
"Pacific/Yap" => { :utc_offset => "+10:00",	:utc_offset_dst => "+10:00" },
"Poland" => { :utc_offset => "+01:00",	:utc_offset_dst => "+02:00" },
"Portugal" => { :utc_offset => "+00:00",	:utc_offset_dst => "+01:00" },
"PRC" => { :utc_offset => "+08:00",	:utc_offset_dst => "+08:00" },
"PST8PDT" => { :utc_offset => "-08:00",	:utc_offset_dst => "-07:00" },
"ROC" => { :utc_offset => "+08:00",	:utc_offset_dst => "+08:00" },
"ROK" => { :utc_offset => "+09:00",	:utc_offset_dst => "+09:00" },
"Singapore" => { :utc_offset => "+08:00",	:utc_offset_dst => "+08:00" },
"Turkey" => { :utc_offset => "+02:00",	:utc_offset_dst => "+03:00" },
"UCT" => { :utc_offset => "+00:00",	:utc_offset_dst => "+00:00" },
"Universal" => { :utc_offset => "+00:00",	:utc_offset_dst => "+00:00" },
"US/Alaska" => { :utc_offset => "-09:00",	:utc_offset_dst => "-08:00" },
"US/Aleutian" => { :utc_offset => "-10:00",	:utc_offset_dst => "-09:00" },
"US/Arizona" => { :utc_offset => "-07:00",	:utc_offset_dst => "-07:00" },
"US/Central" => { :utc_offset => "-06:00",	:utc_offset_dst => "-05:00" },
"US/Eastern" => { :utc_offset => "-05:00",	:utc_offset_dst => "-04:00" },
"US/East-Indiana" => { :utc_offset => "-05:00",	:utc_offset_dst => "-04:00" },
"US/Hawaii" => { :utc_offset => "-10:00",	:utc_offset_dst => "-10:00" },
"US/Indiana-Starke" => { :utc_offset => "-06:00",	:utc_offset_dst => "-05:00" },
"US/Michigan" => { :utc_offset => "-05:00",	:utc_offset_dst => "-04:00" },
"US/Mountain" => { :utc_offset => "-07:00",	:utc_offset_dst => "-06:00" },
"US/Pacific" => { :utc_offset => "-08:00",	:utc_offset_dst => "-07:00" },
"US/Pacific-New" => { :utc_offset => "-08:00",	:utc_offset_dst => "-07:00" },
"US/Samoa" => { :utc_offset => "-11:00",	:utc_offset_dst => "-11:00" },
"UTC" => { :utc_offset => "+00:00",	:utc_offset_dst => "+00:00" },
"WET" => { :utc_offset => "+00:00",	:utc_offset_dst => "+01:00" },
"W-SU" => { :utc_offset => "+03:00",	:utc_offset_dst => "+03:00" },
"Zulu" => { :utc_offset => "+00:00",	:utc_offset_dst => "+00:00" }
}


## Enable Logging so that all Site Creation and Modification are tracked
log = Logger.new(STDOUT)
log.level = Logger::INFO
log.info "Starting up"

# Default Values
=begin
config = YAML.load_file("/Nexpose_Scripts/nexpose.yml") # From file
@host = config["hostname"]
@userid = config["username"]
@password = config["passwordkey"]
@port = config["port"]
=end

@host = '10.1.95.87'
@userid = 'nxadmin'
@password = 'nxadmin'
@port = 3780

## CSV Filename and Path
csv_file = 'sitelist_detail_template_2.csv'

## Enter Credentials and IP for Nexpose connection
nsc = Nexpose::Connection.new(@host, @userid, @password, @port)

## Data structure to describe imported site data from CSV
class SiteInfo
  attr_accessor :name, :template, :engine, :schedule, :blackout_schedule, :description, :included, :excluded, :tz, :dst, :tag

  def initialize(name)
    @name = name
    @included = []
    @excluded = []
  end
end

## Create a hash of sites to import to Nexpose
sites_to_import = {}

## Parse through CSV to populate the hash that was created in the previous step
CSV.foreach(csv_file, {:headers => true, :encoding => "ISO-8859-15:UTF-8"}) do |row|
  next if row['Site Name'].nil?
  name = row['Site Name']
  site = sites_to_import[name]
  if site.nil?
    log.debug "Site #{name} found in CSV file"
    site = SiteInfo.new(name)
    sites_to_import[name] = site
  end
  site.template = row['Scan Template ID'] if row['Scan Template ID']
  site.engine = row['Scan Engine Name'] if row['Scan Engine Name']
  site.schedule = row['Scan Schedule'] if row['Scan Schedule']
  site.blackout_schedule = row['Blackout Schedule'] if row['Blackout Schedule']
  site.description = row['Description'] if row['Description']
  site.included << row['IP Include'].to_s.strip if row['IP Include']
  site.excluded << row['IP Exclude'].to_s.strip if row['IP Exclude']
  site.dst = row['Daylight Savings'].to_s.strip if row['Daylight Savings']
  site.tag = row['Tag'].to_s.strip if row ['Tag']
  site.tz = row['Timezone'].to_s.strip if row ['Timezone']
end

## Get a listing of sites and engines
log.debug "Logging in"

nsc.login

# Get Console Timezone
uri = '/api/2.1/console/time'
response = Nexpose::AJAX.get(nsc, uri)
hash = JSON.parse(response, symbolize_names: true)
console_tz = hash[:timezone]
log.debug "console_tz=#{console_tz}"

at_exit { nsc.logout }

begin
  retries = [3,5,10]
  site_listing = nsc.list_sites
  tag_listing = nsc.list_tags
## try to recover if we encounter network problems
rescue Timeout::Error, Errno::ECONNRESET, Errno::ETIMEDOUT => e
  log.error e
  if delay = retries.shift
    sleep delay
    log.warn "Retrying... - #{site_import.name}"
    retry
  else
    log.error "Retry attempts exceeded, can't proceed without site listing"
    exit(1)
  end
end

begin
  retries = [3,5,10]
  #  engine_listing = nsc.list_engines
  engine_pools = nsc.list_engine_pools
## try to recover if we encounter network problems
rescue Timeout::Error, Errno::ECONNRESET, Errno::ETIMEDOUT => e
  log.error e
  if delay = retries.shift
    sleep delay
    log.warn "Retrying... - #{site_import.name}"
    retry
  else
    log.error "Retry attempts exceeded, can't proceed without engine listing"
    exit(1)
  end
end

## For each site, check if exists, create if needed, then save configuration
log.debug "do site_import"
sites_to_import.each do |site_import|
  site_import = site_import[1]
  log.debug "Working on site - #{site_import.name}"
  begin
    ## if site exists, load it, otherwise create a new one
    site = site_listing.select {|site_summary| site_summary.name == site_import.name}
    log.debug "Checking if site exists - #{site_import.name} - #{site}"
    log.debug "Included IPs - #{site_import.included}"
    log.debug "Excluded IPs - #{site_import.excluded}"
    begin
      site = Site.load(nsc, (site[0].id))
      log.debug "#{site_import.name} found"
    rescue
      log.debug "#{site_import.name} not found"
      site = Site.new(site_import.name)
    end

    ## set the description and scan template if defined in CSV file
    log.debug "description=#{site_import.description}"
    site.description = site_import.description if site_import.description
    log.debug "template_id=#{site_import.template}"
    site.scan_template_id = site_import.template if site_import.template

    ## set the engine id if found based on engine name
    engine = engine_pools.select{|engine_summary| engine_summary.name == site_import.engine}
    log.debug "engine_pool_info=#{engine}"
    unless engine[0].nil?
      site.engine_id = engine[0].id
      log.debug "engine set #{engine[0].id}"
    end

    ## add the schedule
    if site_import.schedule.to_s != ""
      ## convert the schedule string into a suitable format for Nexpose
      schedule_items = site_import.schedule.to_s.split ","
      log.debug "site_import.schedule=#{site_import.schedule.to_s}"

      repeat_cycle = schedule_items[0]
      interval = schedule_items[1]
      start_date = schedule_items[2]
      start_time = schedule_items[3]

      duration = schedule_items[4]
      repeat_type = schedule_items[5]

			# Timezone Considerations
      log.debug "site_import.tz=#{site_import.tz}"
			unless !defined?(site_import.tz)
				# DST Check
        log.debug "site_import.dst=#{site_import.dst}"
				unless !defined?(site_import.dst)
					site_import.dst == "1" ? (zone = "utc_offset_dst") : (zone = "utc_offset")
          log.debug "inside dst"
				else
          log.debug "default to utc_offset"
					zone = "utc_offset"
				end
        log.debug "zone=#{zone}"
				# Construct the time format
				# Adjust for console weirdness
				min = start_time.split(':')[1]
				#start_time = (start_time.split(':')[0].to_i + 1).to_s + ':' + min.to_s
				start_time_new = (start_time[0..1]).to_s + ':' + (start_time[2..3]).to_s

				pre = start_date + " " + start_time[0,2] +":"+start_time[2,2] + " " + timezones["#{site_import.tz}"][:"#{zone}"]
				log.debug "pre=#{pre}"
				# Parse the time and then get the time in the target consoles timezone using new_offset.
				time = DateTime.parse(pre).iso8601
				log.debug "time=#{time}"
				# Format as DateTime object to be passed to Nexpose
				schedtime = DateTime.strptime(time, "%Y-%m-%dT%H:%M:%S%z")
				log.debug "schedtime=#{schedtime}"

			else
				puts "You need to define a timezone in your CSV. Quitting..."
			end

      ## create the schedule and add it to the site configuration
      schedule = Schedule.new(repeat_cycle,interval,schedtime,enabled=true)
      schedule.max_duration = duration
      schedule.repeater_type = repeat_type

			site.schedules.clear
      schedule.start = schedtime
      site.schedules << schedule
    end

    ## add the blackout schedule
    log.debug "@blackout schedule"
	  if site_import.blackout_schedule.to_s != ""
      ## convert the schedule string into a suitable format for Nexpose
      blackout_items = site_import.blackout_schedule.to_s.split ","
      log.debug site_import.blackout_schedule.to_s

      blackout_items = site_import.blackout_schedule.to_s.split ","
      log.debug site_import.blackout_schedule.to_s
      start_date = blackout_items[0]
      start_time = blackout_items[1]
      enabled = blackout_items[2]
      duration = blackout_items[3]
      type = blackout_items[4]
      interval = blackout_items[5]

			# Timezone Considerations
			unless !defined?(site_import.tz)
				# DST Check
				unless !defined?(site_import.dst)
					site_import.dst == "1" ? (zone = "utc_offset_dst") : (zone = "utc_offset")
				else
					zone = "utc_offset"
				end
        log.debug "zone=#{zone}"
				csv_offset = timezones["#{site_import.tz}"][:"#{zone}"]
        log.debug "csv_offset=#{csv_offset}"
puts csv_offset
				time = DateTime.parse((start_date + " " + start_time[0,2] +":"+start_time[2,2] + " " + csv_offset)).iso8601
				# Format as DateTime object to be passed to Nexpose
        log.debug "time=#{time}"
				schedtime = DateTime.strptime(time, "%Y-%m-%dT%H:%M:%S%z")
				puts schedtime
        log.debug "schedtime=#{schedtime}"

			else
				puts "You need to define a timezone in your CSV. Quitting..."
			end


      ## create the schedule and add it to the site configuration
      log.debug "@create schedule"
      schedule = Schedule.new(repeat_cycle,interval,schedtime,enabled=true)
      schedule.max_duration = duration
      schedule.repeater_type = repeat_type

      time_formatted = (schedtime.to_time.to_i ).to_s + "000"

      log.debug "time_formatted=#{time_formatted}"

      ## create the schedule and add it to the site configuration
			blackout_schedule = Blackout.new(time_formatted.to_i, enabled, duration, type, interval)
	  	site.blackouts.clear
      site.blackouts << blackout_schedule
    end

     ##### New IP code ####
#### Setting the Included IPs ####

    site_import.included.each do |ip|
      unless ip.empty?
        ips = ip.split(',').map(&:strip)
        ips.each { |ipa| site.include_asset(ipa) }
      end
    end

#### Setting the Excluded IPs ####

    site_import.excluded.each do |ip|
      unless ip.empty?
        site.exclude_asset(ip)
      end
    end

=begin  #### OLD IP CODE ####
     ## add the included IP addresses/ranges to the site configuration
    site_import.included.each do |ip|
      next if ip.empty?
      if ip.include? '-'
        begin
        from, to = ip.split(' - ')
        rescue
          from, to = ip.split('-')
          end
        site.included_addresses << IPRange.new(from, to)
      else
        begin
            site.included_addresses << IPRange.new(ip)
        rescue
            log.warn "Error adding #{ip} to #{site.name}"
        end
      end
    end

    ## add the excluded IP addresses/ranges to the site configuration
    site_import.excluded.each do |ip|
      next if ip.empty?
        if ip.split(' - ').size == 2
          from, to = ip.split(' - ')
          site.excluded_addresses <<  IPRange.new(from, to)
        else
          site.excluded_addresses << IPAddr.new(ip)
        end
    end
=end

    ## save the site configuration
    begin
      retries = [3,5,10]
      log.debug "Save site"
      site.save(nsc)
      log.info "Saved site #{site.name} (id:#{site.id})"

      ## Add the specified tag as a location tag
      begin
          if site_import.tag != ""
              tag_to_add = tag_listing.select {|tag_summary| site_import.tag == tag_summary.name}
              full_tag = Tag.load(nsc, tag_to_add[0].id)
              #puts full_tag
              # puts tag_to_add[0].id
              # site.tags << tag_to_add[0]
              full_tag.add_to_site(nsc, site.id)
              log.info "Saved tag #{full_tag.name} to site #{site.name}"
          end
      rescue
        log.debug "Tag error"
      end

    ## try to recover if we encounter network problems
    rescue Timeout::Error, Errno::ECONNRESET, Errno::ETIMEDOUT => e
      log.error e
      if delay = retries.shift
        sleep delay
        log.warn "Retrying... - #{site_import.name}"
        retry
      else
        log.warn "Retry attempts exceeded, moving on to the next site - #{site_import.name}"
      end
    end
  ## log Nexpose API errors and move on
  rescue Nexpose::APIError => e
    ## if you hit ctrl+c, exit instead of resuming
    if e.to_s.include? "Received a user interrupt"
      log.warn "Exit requested by user"
      exit(0)
    end
    log.error "#{e.message} in site #{site_import.name}"
  end
end
