From: agk@sourceware.org <agk@sourceware.org>
Date: 16 Nov 2006 16:44:49 -0000
Subject: LVM2 ./WHATS_NEW scripts/lvm_dump.sh man/lvmdump.8
Message-ID: <20061116164449.4162.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2006-11-16 16:44:48

Modified files:
	.              : WHATS_NEW 
	scripts        : lvm_dump.sh 
Added files:
	man            : lvmdump.8 

Log message:
	Enhance lvm_dump.sh for sysreport integration and add man page.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.497&r2=1.498
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvmdump.8.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/scripts/lvm_dump.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2

--- LVM2/WHATS_NEW	2006/11/14 15:28:50	1.497
+++ LVM2/WHATS_NEW	2006/11/16 16:44:48	1.498
@@ -1,5 +1,6 @@
 Version 2.02.15 -
 ====================================
+  Enhance lvm_dump.sh for sysreport integration and add man page.
   Fix --autobackup argument which could never disable backups.
   Fix a label_verify error path.
 
/cvs/lvm2/LVM2/man/lvmdump.8,v  -->  standard output
revision 1.1
--- LVM2/man/lvmdump.8
+++ -	2006-11-16 16:44:48.918414000 +0000
@@ -0,0 +1,40 @@
+.TH LVMDUMP "8" "" "Red Hat, Inc."
+.SH NAME
+lvmdump - create lvm2 information dumps for diagnostic purposes
+.SH SYNOPSIS
+\fBlvmdump\fP [options] [-d directory]
+.SH DESCRIPTION
+\fBlvmdump\fP is a tool to dump various information concerning LVM2. By default, it creates a tarball suitable for submission along with a problem report.
+.PP
+The content of the tarball is as follows:
+.br
+- dmsetup info
+.br
+- table of currently running processes
+.br
+- recent entries from /var/log/messages (containing system messages)
+.br
+- complete lvm configuration and cache
+.br
+- list of device nodes present under /dev
+.br
+- if enabled with -m, metadata dump will be also included
+.br
+- if enabled with -a, debug output of vgscan, pvscan and list of all available volume groups, physical volumes and logical volumes will be included
+.br
+- if enabled with -c, cluster status info
+.SH OPTIONS
+.TP
+\fB\-h\fR \(em print help message
+.TP
+\fB\-a\fR \(em advanced collection 
+\fBWARNING\fR: if lvm is already hung, then this script may hang as well if \fB\-a\fR is used
+.TP
+\fB\-m\fR \(em gather LVM metadata from the PVs
+This option generates a 1:1 dump of the metadata area from all PVs visible to the system, which can cause the dump to increase in size considerably. However, the metadata dump may represent a valuable diagnostic resource.
+.TP
+\fB\-d\fR directory \(em dump into a directory instead of tarball
+By default, lvmdump will produce a single compressed tarball containing all the information. Using this option, it can be instructed to only produce the raw dump tree, rooted in \fBdirectory\fP.
+.TP
+\fB\-c\fR \(em if clvmd is running, gather cluster data as well
+.PP
--- LVM2/scripts/lvm_dump.sh	2006/10/05 18:42:33	1.1
+++ LVM2/scripts/lvm_dump.sh	2006/11/16 16:44:48	1.2
@@ -10,7 +10,7 @@
 	echo "    -a advanced collection - warning: if lvm is already hung,"
 	echo "       then this script may hang as well if -a is used"
 	echo "    -m gather LVM metadata from the PVs"
-	echo "    -d dump directory to place data in (default=/tmp/lvm_dump.\$\$)"
+	echo "    -d <directory> dump into a directory instead of tarball"
 	echo "    -c if running clvmd, gather cluster data as well"
 	echo ""
 	
@@ -22,9 +22,10 @@
 metadata=0
 while getopts :acd:hm opt; do
 	case $opt in 
+		s)      sysreport=1 ;;
 		a)	advanced=1 ;;
 		c)	clustered=1 ;;
-		d)	lvm_dir=$OPTARG ;;
+		d)	userdir=$OPTARG ;;
 		h)	usage ;;
 		m)	metadata=1 ;;
 		:)	echo "$0: $OPTARG requires a value:"; usage ;;
@@ -33,86 +34,119 @@
 	esac
 done
 
-dir=`mktemp -d -p /tmp lvm_dump.XXXXXX` || exit 2
-lvm_dir="$dir/lvm_dump"
+DATE=`/bin/date -u +%G%m%d%k%M%S | /usr/bin/tr -d ' '`
+if test -n "$userdir"; then
+	dir="$userdir"
+else
+	dirbase="lvmdump-$HOSTNAME-$DATE"
+	dir="$HOME/$dirbase"
+fi
+
+if test -e $dir; then
+	echo $dir already exists, aborting >&2
+	exit 2
+fi
+
+if ! mkdir -p $dir; then
+	echo Could not create $dir >&2
+	exit 3
+fi
+
+log="$dir/lvmdump.log"
+
+myecho() {
+	echo "$@"
+	echo "$@" >> $log
+}
+
+log() {
+	echo "$@" >> $log
+	eval "$@"
+}
 
 echo " "
-echo "Creating dump directory: $lvm_dir"
+myecho "Creating dump directory: $dir"
 echo " "
 
-mkdir -p $lvm_dir || exit 3
-
 if (( $advanced )); then
-	echo "Gathering LVM volume info..."
+	myecho "Gathering LVM volume info..."
 
-	echo "  vgscan..."
-	vgscan -vvvv > $lvm_dir/vgscan 2>&1
+	myecho "  vgscan..."
+	log "vgscan -vvvv > $dir/vgscan 2>&1"
 
-	echo "  pvscan..."
-	pvscan -v >> $lvm_dir/pvscan 2>/dev/null
+	myecho "  pvscan..."
+	log "pvscan -v >> $dir/pvscan 2>> $log"
 
-	echo "  lvs..."
-	lvs -a -o +devices >> $lvm_dir/lvs 2>/dev/null
+	myecho "  lvs..."
+	log "lvs -a -o +devices >> $dir/lvs 2>> $log"
 
-	echo "  pvs..."
-	pvs -a -v > $lvm_dir/pvs 2>/dev/null
+	myecho "  pvs..."
+	log "pvs -a -v > $dir/pvs 2>> $log"
 
 	echo "  vgs..."
-	vgs -v > $lvm_dir/vgs 2>/dev/null
+	log "vgs -v > $dir/vgs 2>> $log"
 fi
 
 if (( $clustered )); then
-	echo "Gathering cluster info..."
-	echo "STATUS: " > $lvm_dir/cluster_info
-	echo "----------------------------------" >> $lvm_dir/cluster_info
-	cman_tool status >> $lvm_dir/cluster_info
-	echo " " >> $lvm_dir/lvm_info
-
-	echo "SERVICES: " >> $lvm_dir/cluster_info
-	echo "----------------------------------" >> $lvm_dir/cluster_info
-	cman_tool services >> $lvm_dir/cluster_info
-	echo " " >> $lvm_dir/lvm_info
-fi
-
-echo "Gathering LVM & device-mapper version info..."
-echo "LVM VERSION:" > $lvm_dir/versions
-lvs --version >> $lvm_dir/versions
-echo "DEVICE MAPPER VERSION:" >> $lvm_dir/versions
-dmsetup --version >> $lvm_dir/versions
-
-echo "Gathering dmsetup info..."
-dmsetup info -c > $lvm_dir/dmsetup_info
-dmsetup table > $lvm_dir/dmsetup_table
-dmsetup status > $lvm_dir/dmsetup_status
-
-echo "Gathering process info..."
-ps alx > $lvm_dir/ps_info
+	myecho "Gathering cluster info..."
+	echo "STATUS: " > $dir/cluster_info
+	echo "----------------------------------" >> $dir/cluster_info
+	log "cman_tool status >> $dir/cluster_info 2>> $log"
+	echo " " >> $dir/lvm_info
+
+	echo "SERVICES: " >> $dir/cluster_info
+	echo "----------------------------------" >> $dir/cluster_info
+	log "cman_tool services >> $dir/cluster_info 2>> $log"
+	echo " " >> $dir/lvm_info
+fi
+
+myecho "Gathering LVM & device-mapper version info..."
+echo "LVM VERSION:" > $dir/versions
+lvs --version >> $dir/versions 2>> $log
+echo "DEVICE MAPPER VERSION:" >> $dir/versions
+dmsetup --version >> $dir/versions 2>> $log
+
+myecho "Gathering dmsetup info..."
+log "dmsetup info -c > $dir/dmsetup_info 2>> $log"
+log "dmsetup table > $dir/dmsetup_table 2>> $log"
+log "dmsetup status > $dir/dmsetup_status 2>> $log"
+
+myecho "Gathering process info..."
+log "ps alx > $dir/ps_info 2>> $log"
 
-echo "Gathering console messages..."
-tail -n 75 /var/log/messages > $lvm_dir/messages
+myecho "Gathering console messages..."
+log "tail -n 75 /var/log/messages > $dir/messages 2>> $log"
 
-echo "Gathering /etc/lvm info..."
-cp -a /etc/lvm $lvm_dir/lvm
+myecho "Gathering /etc/lvm info..."
+log "cp -a /etc/lvm $dir/lvm 2>> $log"
 
-echo "Gathering /dev listing..."
-ls -la /dev > $lvm_dir/dev_listing
+myecho "Gathering /dev listing..."
+log "ls -la /dev > $dir/dev_listing 2>> $log"
 
 if (( $metadata )); then
-	echo "Gathering LVM metadata from Physical Volumes..."
+	myecho "Gathering LVM metadata from Physical Volumes..."
 
-	mkdir -p $lvm_dir/metadata
+	log "mkdir -p $dir/metadata"
 
-	for pv in `pvs --noheadings -o name`
+	pvs="$(pvs --separator , --noheadings --units s --nosuffix -o name,pe_start 2>> $log | \
+		sed -e 's/^ *//')"
+	for line in "$pvs"
 	do
-		echo "  $pv"
-		name=`basename $pv`
-		dd if=$pv of=$lvm_dir/metadata/$name bs=512 count=`pvs --noheadings --nosuffix --units s -o pe_start $pv | tr -d \ `
-	done 2>/dev/null
+		pv="$(echo $line | cut -d, -f1)"
+		pe_start="$(echo $line | cut -d, -f2)"
+		name="$(basename $pv)"
+		myecho "  $pv"
+		log "dd if=$pv of=$dir/metadata/$name bs=512 count=$pe_start 2>> $log"
+	done
 fi
 
-lvm_dump=$lvm_dir.tgz
-echo "Creating tarball $lvm_dump..."
-tar czf $lvm_dump $lvm_dir 2>/dev/null
+if test -z "$userdir"; then
+	lvm_dump="$dirbase.tgz"
+	myecho "Creating report tarball in $HOME/$lvm_dump..."
+	cd $HOME
+	tar czf $lvm_dump $dirbase 2>/dev/null
+	rm -rf $dir
+fi
 
 exit 0
 


