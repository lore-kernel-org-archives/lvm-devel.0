From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Fri, 14 May 2010 13:14:55 +0200
Subject: [PATCH 1/1] Use /bin/bash instead of /bin/sh
In-Reply-To: <20100514104002.GQ2377@agk-dp.fab.redhat.com>
References: <cover.1273825538.git.zkabelac@redhat.com>	<68fd26e48c7d6d792d4d1af9551a0ba070e022d4.1273825538.git.zkabelac@redhat.com>
	<20100514104002.GQ2377@agk-dp.fab.redhat.com>
Message-ID: <4BED30AF.5030706@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 14.5.2010 12:40, Alasdair G Kergon napsal(a):
> On Fri, May 14, 2010 at 10:28:25AM +0200, Zdenek Kabelac wrote:
>> Use /bin/bash for scripts using bashisms.
>> For all of them 'checkbashisms' command reports miscelanous things
>> available only in nonstandard shell extensions like bash.
>  
> Please post the output so we can see.
> 

Some of them could be easily fixed - some of them are trickier (i.e.
${RANDOM}) - as we already use bash for other scripts anyway - I've considered
it's fairly easier to use bash for these as well...

Zdenek

------------------

scripts/clvmd_fix_conf.sh
possible bashism in scripts/clvmd_fix_conf.sh line 35 (${foo:3[:1]}):
  if [ "${PREFIX:0:1}" != "/" ]
possible bashism in scripts/clvmd_fix_conf.sh line 135 (echo -e):
    echo -e $SEDCMD > $SCRIPTFILE
------------------
scripts/fsadm.sh
possible bashism in scripts/fsadm.sh line 63 ($RANDOM):
TEMPDIR="${TMPDIR:-/tmp}/${TOOL}_${RANDOM}$$/m"
possible bashism in scripts/fsadm.sh line 119 (trap with signal numbers):
	trap '' 2
------------------
scripts/last_cvs_update.sh
possible bashism in scripts/last_cvs_update.sh line 36 (alternative test
command ([[ foo ]] should be [ foo ])):
if [[ -z $1 ]];
possible bashism in scripts/last_cvs_update.sh line 39 (alternative test
command ([[ foo ]] should be [ foo ])):
 if [[ $1 == "-h" ]];
possible bashism in scripts/last_cvs_update.sh line 39 (should be 'b = a'):
 if [[ $1 == "-h" ]];
possible bashism in scripts/last_cvs_update.sh line 43 (alternative test
command ([[ foo ]] should be [ foo ])):
   if [[ -d $1 ]]
possible bashism in scripts/last_cvs_update.sh line 53 (alternative test
command ([[ foo ]] should be [ foo ])):
if [[ -f $path/CVS/Tag ]];
------------------
scripts/lvmconf.sh
possible bashism in scripts/lvmconf.sh line 19 ('function' is useless):
function usage
possible bashism in scripts/lvmconf.sh line 34 ('function' is useless):
function parse_args
possible bashism in scripts/lvmconf.sh line 80 ('function' is useless):
function validate_args
possible bashism in scripts/lvmconf.sh line 97 (${foo:3[:1]}):
        if [ "${LOCKINGLIBDIR:0:1}" != "/" ]
possible bashism in scripts/lvmconf.sh line 236 (echo -e):
    echo -e $SEDCMD > $SCRIPTFILE
------------------
scripts/lvmconf_lockingtype2.sh
possible bashism in scripts/lvmconf_lockingtype2.sh line 19 ('function' is
useless):
function usage
possible bashism in scripts/lvmconf_lockingtype2.sh line 34 ('function' is
useless):
function parse_args
possible bashism in scripts/lvmconf_lockingtype2.sh line 80 ('function' is
useless):
function validate_args
possible bashism in scripts/lvmconf_lockingtype2.sh line 99 (${foo:3[:1]}):
        if [ "${LOCKINGLIBDIR:0:1}" != "/" ]
possible bashism in scripts/lvmconf_lockingtype2.sh line 233 (echo -e):
    echo -e $SEDCMD > $SCRIPTFILE
------------------
scripts/vgimportclone.sh
possible bashism in scripts/vgimportclone.sh line 40 (should be >word 2>&1):
"$LVM" version >& /dev/null || die 2 "Could not run lvm binary '$LVM'"
possible bashism in scripts/vgimportclone.sh line 43 ('function' is useless):
function getvgname {
possible bashism in scripts/vgimportclone.sh line 55 (alternative test command
([[ foo ]] should be [ foo ])):
    while [[ "${VGLIST}" =~ "${NAME}" ]]
possible bashism in scripts/vgimportclone.sh line 64 ('function' is useless):
function checkvalue {
possible bashism in scripts/vgimportclone.sh line 73 ('function' is useless):
function usage {
possible bashism in scripts/vgimportclone.sh line 89 ('function' is useless):
function cleanup {
possible bashism in scripts/vgimportclone.sh line 103 ($UID should be "$(id
-ru)"):
if [ "$UID" != "0" -a "$EUID" != "0" ]
possible bashism in scripts/vgimportclone.sh line 103 ($EUID should be "$(id
-u)"):
if [ "$UID" != "0" -a "$EUID" != "0" ]
possible bashism in scripts/vgimportclone.sh line 125 (trap with signal numbers):
trap  cleanup 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18
possible bashism in scripts/vgimportclone.sh line 154 (let ...):
            let VERBOSE_COUNT=VERBOSE_COUNT+1
possible bashism in scripts/vgimportclone.sh line 320 (alternative test
command ([[ foo ]] should be [ foo ])):
    if [[ "${PVLIST}" =~ "unknown" ]]
------------------


