Received: from smtp-out1-06.simnet.is (smtp-out1-06.simnet.is [194.105.231.13])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id DF81B16F0FE
	for <lvm-devel@lists.linux.dev>; Sat, 22 Feb 2025 11:12:53 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=194.105.231.13
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1740222779; cv=none; b=B34C4k54bZ3kqDbaI6Whcp5OG3AdvBol6xi/0dCtXjzzWkDGp98K+yxXbnWhzFzAziOZvftpFCs1vAly7PCIrF/Iws/0oDEQYeopSP5gLKFx67KcE2MCxUKsyyzDwKutRbKY5qsKY0e0p6C6pScSvTc0IieDXP0Lb1kQEx0VKyQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1740222779; c=relaxed/simple;
	bh=mOHcMZgTjPMFsX0G8q1DchBw8SO3GHjG0hT1ulPFc3c=;
	h=Date:From:To:Cc:Subject:Message-ID:MIME-Version:Content-Type:
	 Content-Disposition; b=X8YU6vSEUjBPPDD9EGRSUNxEnqrBfHXjVk5Dli5+TKXMslIPU4+hoZ7Zkcn9CthocsWgCsawuw9FuHKJmcVToWQ8Uecy4DnRBIxpzDRjzFrlOTY6/aiymPERwm6D8BGic1PjS9q9vvG/NIZ0w4SPJdfhYw9JBt+JwlNRaeIi+jo=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=simnet.is; spf=pass smtp.mailfrom=simnet.is; dkim=pass (2048-bit key) header.d=simnet.is header.i=@simnet.is header.b=ZcrT6rpU; arc=none smtp.client-ip=194.105.231.13
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=simnet.is
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=simnet.is
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=simnet.is header.i=@simnet.is header.b="ZcrT6rpU"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
  d=simnet.is; i=@simnet.is; q=dns/txt; s=sel1;
  t=1740222774; x=1771758774;
  h=date:from:to:cc:subject:message-id:mime-version;
  bh=FZKPCy2MkaNzh6mtKOf7k7r1emcMIhBrFHPS0D5ixos=;
  b=ZcrT6rpUxGxHjcEYCTfPDE0j/wgyTNR0PNx9KaoWFpK/NhvVY57BN4yp
   /5mmrQ6RIo/0iQCWtYXCC4xFOv8s/kXZZLG4e8AhSDBQ+TpU5cIqVvtvQ
   lxxsWfYzUf8MTfDPctm1McyfKx6R1bIS47zKaItHGEDnqTEGU4+QmQLt1
   Doz+I3AiV7WhN0cScXs13rtP6m/S5vQ9+nIFcLLpa7CVCvehZV2tDaRAQ
   5AD4MnH7Y4wwtpHNypOmN9Q/a98X71J9qmYOHaSnQF6KF4w3e13kylisE
   g4wz40d4j6681GsSqXEG+ys0raAmfEmhMhqsubb8rfxqlGaY2iowBQr1l
   A==;
X-CSE-ConnectionGUID: nraAvAJ7Twi+RQJ6gsDmOw==
X-CSE-MsgGUID: cSQbiN+TSGiT53BFsZPU4w==
Authentication-Results: smtp-out-06.simnet.is; dkim=none (message not signed) header.i=none
X-SBRS: 3.3
X-IPAS-Result: =?us-ascii?q?A2FVAAC5rLlnhVjoacJaGgEBAQEBAQEBAQEDAQEBARIBA?=
 =?us-ascii?q?QEBAgIBAQEBQIFBAwEBAQELAYIbKH2BZIgljiGBFpA0jE0UgXIHAQEBDzEPB?=
 =?us-ascii?q?AQBAQSBU4MwixIoNgcOAQIEAQEBAQMCAwEBAQEBAQEBAQEBCwEBBgEBAQEBA?=
 =?us-ascii?q?QYHAhABAQEBQA47hTVGDYUsLIErAQxSLXyDKQGCZK4lgQEzgQGDHNsYgV4Qg?=
 =?us-ascii?q?UgBhWuCYwGFa4R3PAaCDYEVMgOBBm1KB2+EBiMBRYYYBIIYF4FAggJegQyBb?=
 =?us-ascii?q?IRlVII5gReBNh0cL0aBDlGBLIFWgniBJCASg1+CWyOJOkiBIQNZLAFVEw0KC?=
 =?us-ascii?q?wcFgXEDNQwLLhUygRRDNzeCDmlJOgINAjWCHnyCK4JbgXuEQ4RHhVSCEYs3g?=
 =?us-ascii?q?yQdNgoDCxgNSBEsNxQbRG4HoAk9gzcJAQkmDzMBARUXBAw3BxMBCjZDIwoMB?=
 =?us-ascii?q?wMwAgQECwUYASETCwsykj4mATGPWIFEgyqJJZNTgT6EJYZcgzGCC5VKMyKDY?=
 =?us-ascii?q?YFXizCGOgw6iwiHQ5h9gligbRoCGRk3hGaBbgqCBSwHGggwO4JnCUkZD44HI?=
 =?us-ascii?q?wMWgQwBCIcgxEZ4PAIHCwEBAwmGS4kvKwGBUwEB?=
IronPort-PHdr: A9a23:EU2JrRGi5VjnN52bPP43251Gfg0Y04WdBeZ0woEil6oLdbm/usy8e
 lfe4PNgkBnIRtaT5/FFjr/QtKbtESwF7I2auX8POJpLS1ceiMoQkgBhSM6IAEH2NrjrOio9G
 skqaQ==
IronPort-Data: A9a23:HK5iL64qnHlpVgNlVR65hQxRtL/AchMFZxGqfqrLsTDasI4TYxWz/
 BJMATLpZ67UfDe3OcciNc7jsQ9Gp57leuUTQAVpr3hhRSsRp5ebWo7II0v6Y3PId8afEk4+4
 Z5AZoGdfZk9Ry7S+k38aua78SQt2KvQGLTwULbJZXl6HlFuRk/N5f4Ed8sR2+aE1vDjXF7X5
 rse2vHiBWNJstIM3gg856eYpQ9ypLKi/j8ZsFJWiZtj51OAmSEbBc8Se//hI3CkToQOFLHkG
 +udkuvppTnS8059VIqon7ylK0EDH+SIYFLS0idaAfL/3UUdqidogvtmZZLwBasvZxChxridn
 /0U68TsF2/FR5HxpdjxOvUg/0tWMqBA9aXOJT61rMOIp6GtWyCwnP9nXBo9MN0V9ut+Xz9Hq
 PJGIjpdNkHTirO7nLzhFeMz1s8tc5CyY9lF5Sw+lT2EXPgrHsGdTvmSuY5W129YaqyiZRr7T
 5NxhW1HNUWaOXWjQ2sqNa/SvNtEp1GgemIFoQ+frKRm7TOPkwIr27HmaoeEJtKHSJpYlxvE9
 kvLrj/zav04HIXEkGLaqBpApQNucQfTAt96+GiQr6Yy6LGr7jVNTkVQDR3j/KXRZneWA7p3M
 1YT9jclsZ88/UmqSsiVdxCjqRZohDZFMzZrO7N8sVrlJpb8uV7DWzBeFGQZMrTKiedvLdAU/
 g7Y9z/WLWQHXI29ERq16rqSpDWuDikZRUdqTTMEVwYM/+74q4g1iB/VJv47eEJipoSocd1Y6
 2niQBkW393/v+ZSv0mI1QyvbwaXm3T8ZlVdCjM78Y6SxlgRiIaNP+RE4LVAhBpKBN7xolKp5
 BDolyUChQyn4F7keCGlGY0w8L+VC/mtNifVqEBGPcYd6DXuwUeBI49LzDRZOxI8WioEUWeBj
 E77pwJK+NpBPX6yd6hncsfpUYI0zLP8U9X+PhzWRoMfPt4oLFLBpno0Ix7At4zuuBFEfaUXM
 5izasepC3sGT6V8pNazb7xNiuN3n3lvrY/VbZvA9h6m9/miX1GUdepeGnWVXNgEsLzR9W059
 P4Ea5vblEQDOAHkWQHM7IQWLEwiJ2U0Htb6psZWf+jFJRBpcEklFfqUzb4/dohNm6VOivyO+
 nC7R18exFfh7UArMi2Ua2t/LaHuWI5lqmIqeHR2e0ipwGRlYJ3HALojm4Ufe6Mu3fJK76FIU
 PhGQfyiXPtUZjHg5GFIBXXil7BKeBOujAOIGiOqZjkjYpJtLzAlHPe4L2MDEwFTVkKKWdsCn
 lG26u/Mabs4LzmO4e7IaemzikGwuGAHn/JjGhOSZMdSY1mq8ZMCx83NYh0ffZhkxfbrn2ryO
 +Oq7fEw/7alT2gdq4ChuEx8h931e9aS52IDd4Uh0Z64NDPB4k2oypJaXeCDcFj1DTyooPz8P
 7oMk6qkaZXreWqmVaIhS96HKopjvrPSS0NylFs0dJk2Rw33Ue05fBFqI+Ee6vcWrlOmhedGc
 hnTqogFaOnh1DLNFV8VLUIlYIy+OQI8x1HvAQAOCByivkdfpePbOW0MZEPkoHIGc9NI3HYNm
 rxJVDg+sFfn0kJC3xfvpnw8yllg2VRZC/587MpDWdKz4ufpo3kbCaHh5ubNyMnnQ71x3oMCf
 ld4WIKqa2xg+3f/
IronPort-HdrOrdr: A9a23:ECXGwqqtoDKPicJtdVQnD7QaV5r1eYIsimQD101hICF9WOOyso
 SHkfkB2QXv4QxhIE3I+OrvBEDkex+yyXcb2+ks1NuZLWvbURKTXftfBNLZskDd8k7Fl9K1t5
 0QCJSWYeeYZTVHZK3BkWqF+rgbsby6GK3Dv5a7859gJzsaEp2J5W1Ce2Cm+pMcfmJ77apVLv
 ChDz181l2dRUg=
X-Talos-CUID: =?us-ascii?q?9a23=3AFl3BXGv13EHdZ3MOcGwWUCQ06IsjaHT00l7yfHO?=
 =?us-ascii?q?nCCVTcZ/LRkS8/YR7xp8=3D?=
X-Talos-MUID: =?us-ascii?q?9a23=3AOQ8cbg7vrCg5IWADFgVriJOfxoxj2J2kCWZOra4?=
 =?us-ascii?q?puvXZbgZeIAWlsWioF9o=3D?=
X-IronPort-Anti-Spam-Filtered: true
X-IronPort-AV: E=Sophos;i="6.13,307,1732579200"; 
   d="8'?diff'?bugs'?scan'208";a="38344119"
Received: from vist-zimproxy-02.vist.is ([194.105.232.88])
  by smtp-out-06.simnet.is with ESMTP/TLS/ECDHE-RSA-AES256-GCM-SHA384; 22 Feb 2025 11:11:41 +0000
Received: from localhost (localhost [127.0.0.1])
	by vist-zimproxy-02.vist.is (Postfix) with ESMTP id 18B1F4446310;
	Sat, 22 Feb 2025 11:11:41 +0000 (GMT)
Received: from vist-zimproxy-02.vist.is ([127.0.0.1])
 by localhost (vist-zimproxy-02.vist.is [127.0.0.1]) (amavis, port 10032)
 with ESMTP id ZP-GCMp6oIoP; Sat, 22 Feb 2025 11:11:38 +0000 (GMT)
Received: from localhost (localhost [127.0.0.1])
	by vist-zimproxy-02.vist.is (Postfix) with ESMTP id B8C1C444632B;
	Sat, 22 Feb 2025 11:11:38 +0000 (GMT)
Received: from vist-zimproxy-02.vist.is ([127.0.0.1])
 by localhost (vist-zimproxy-02.vist.is [127.0.0.1]) (amavis, port 10026)
 with ESMTP id nWyPUumQ7KWG; Sat, 22 Feb 2025 11:11:38 +0000 (GMT)
Received: from kassi.invalid.is (85-220-33-163.dsl.dynamic.simnet.is [85.220.33.163])
	by vist-zimproxy-02.vist.is (Postfix) with ESMTPS id 8CCA44446310;
	Sat, 22 Feb 2025 11:11:38 +0000 (GMT)
Received: from bg by kassi.invalid.is with local (Exim 4.98)
	(envelope-from <bg@kassi.invalid.is>)
	id 1tlnQ1-00000000382-2ZGh;
	Sat, 22 Feb 2025 11:11:37 +0000
Date: Sat, 22 Feb 2025 11:11:37 +0000
From: Bjarni Ingi Gislason <bjarniig@simnet.is>
To: lvm-devel@lists.linux.dev
Cc: Debian Bug Tracking System <submit@bugs.debian.org>
Subject: dmsetup.8: Some remarks and a patch with editorial changes for this
 man page
Message-ID: <174022250690.11933.16308959540537242873.reportbug@kassi.invalid.is>
Precedence: bulk
X-Mailing-List: lvm-devel@lists.linux.dev
List-Id: <lvm-devel.lists.linux.dev>
List-Subscribe: <mailto:lvm-devel+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:lvm-devel+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="pc6zmQobCfgffrNE"
Content-Disposition: inline
X-Mailer: reportbug 13.1.0


--pc6zmQobCfgffrNE
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Package: dmsetup
Version: 2:1.02.201-1
Severity: minor
Tags: patch

   * What led up to the situation?

     Checking for defects with a new version

test-[g|n]roff -mandoc -t -K utf8 -rF0 -rHY=0 -rCHECKSTYLE=10 -ww -z < "man page"

  [Use "groff -e ' $' -e '\\~$' <file>" to find obvious trailing spaces.]

  ["test-groff" is a script in the repository for "groff"; is not shipped]
(local copy and "troff" slightly changed by me).

  [The fate of "test-nroff" was decided in groff bug #55941.]

   * What was the outcome of this action?

Output from "test-groff  -mandoc -t -K utf8 -rF0 -rHY=0 -rCHECKSTYLE=10 -ww -z ":

an.tmac:<stdin>:11: style: use of deprecated macro: .PD
an.tmac:<stdin>:37: misuse, warning: .BR is for at least 2 arguments, got 1
	Use macro '.B' for one argument or split argument.
an.tmac:<stdin>:37: misuse, warning: .IR is for at least 2 arguments, got 1
	Use macro '.I' for one argument or split argument.
an.tmac:<stdin>:408: style: use of deprecated macro: .PD
an.tmac:<stdin>:614: misuse, warning: .BR is for at least 2 arguments, got 1
	Use macro '.B' for one argument or split argument.
an.tmac:<stdin>:614: misuse, warning: .IR is for at least 2 arguments, got 1
	Use macro '.I' for one argument or split argument.
an.tmac:<stdin>:656: style: 1 leading space(s) on input line
an.tmac:<stdin>:657: style: 1 leading space(s) on input line
an.tmac:<stdin>:658: style: 1 leading space(s) on input line
an.tmac:<stdin>:659: style: 1 leading space(s) on input line
an.tmac:<stdin>:660: style: 1 leading space(s) on input line
an.tmac:<stdin>:661: style: 1 leading space(s) on input line
an.tmac:<stdin>:662: style: 1 leading space(s) on input line
an.tmac:<stdin>:950: style: 1 leading space(s) on input line
an.tmac:<stdin>:951: style: 1 leading space(s) on input line
an.tmac:<stdin>:952: style: 1 leading space(s) on input line
an.tmac:<stdin>:953: style: 1 leading space(s) on input line
an.tmac:<stdin>:954: style: 1 leading space(s) on input line
an.tmac:<stdin>:1062: style: use of deprecated macro: .PD
an.tmac:<stdin>:1074: style: use of deprecated macro: .PD


   * What outcome did you expect instead?

     No output (no warnings).

-.-

  General remarks and further material, if a diff-file exist, are in the
attachments.


-- System Information:
Debian Release: trixie/sid
  APT prefers testing
  APT policy: (500, 'testing')
Architecture: amd64 (x86_64)

Kernel: Linux 6.12.12-amd64 (SMP w/2 CPU threads; PREEMPT)
Locale: LANG=is_IS.iso88591, LC_CTYPE=is_IS.iso88591 (charmap=ISO-8859-1), LANGUAGE not set
Shell: /bin/sh linked to /usr/bin/dash
Init: sysvinit (via /sbin/init)

Versions of packages dmsetup depends on:
ii  libc6               2.40-7
ii  libdevmapper1.02.1  2:1.02.201-1

dmsetup recommends no packages.

dmsetup suggests no packages.

-- no debconf information

--pc6zmQobCfgffrNE
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="chk_man.err.dmsetup.8"

Input file is dmsetup.8

Output from "mandoc -T lint  dmsetup.8": (shortened list)

      1 input text line longer than 80 bytes: Each device is speci...
      1 input text line longer than 80 bytes: Ensure \fI/dev/mappe...
      1 input text line longer than 80 bytes: Ensure existing devi...
      1 input text line longer than 80 bytes: If \fItable\fP or \f...
      1 input text line longer than 80 bytes: Loads \fItable\fP or...
      1 input text line longer than 80 bytes: Supports thin provis...
      1 input text line longer than 80 bytes: The minor number of ...
      1 input text line longer than 80 bytes: Use a backslash to e...
      1 input text line longer than 80 bytes: Wake any processes t...
      1 input text line longer than 80 bytes: based on the \fB\-\-...
      1 input text line longer than 80 bytes: of the dmsetup proce...
      2 input text line longer than 80 bytes: test-linear\-small,,...
      1 input text line longer than 80 bytes: the \fB\-\-noflush\f...
      1 input text line longer than 80 bytes: the command will try...
      1 input text line longer than 80 bytes: to check this.)  If ...
      1 skipping paragraph macro: br after sp

-.-.

Output from "test-groff -mandoc -t -ww -z dmsetup.8": (shortened list)

     73 	Use macro '.B' for one argument or split argument.
     41 	Use macro '.I' for one argument or split argument.
     73 .BR is for at least 2 arguments, got 1
     41 .IR is for at least 2 arguments, got 1

-.-.

Lines containing '\c' (' \c' does not make sense):

423:.BI \%dmsetup\ info\ \-c\ \-\-noheadings\ \-j \ major\  \-m \ minor \c

-.-

Change '-' (\-) to '\(en' (en-dash) for a (numeric) range.
GNU gnulib has recently (2023-06-18) updated its
"build_aux/update-copyright" to recognize "\(en" in man pages.

dmsetup.8:485:Character whitelist: 0\-9, A\-Z, a\-z, #+\-.:=@_. This whitelist is

-.-.

Change (or include a "FIXME" paragraph about) misused SI (metric)
numeric prefixes (or names) to the binary ones, like Ki (kibi), Mi
(mebi), Gi (gibi), or Ti (tebi), if indicated.
If the metric prefixes are correct, add the definitions or an
explanation to avoid misunderstanding.

947:will map the first chunk (16k) as follows:

-.-.

Add a (no-break, "\ " or "\~") space between a number and a unit,
as these are not one entity.

947:will map the first chunk (16k) as follows:

-.-.

Use "\e" to print the escape character instead of "\\" (which gets
interpreted in copy mode).

487:with its hex value (two digits) prefixed by \\x.

-.-.

Strings longer than 3/4 of a standard line length (80)
Use "\:" to split the string at the end of an output line, for example a
long URL (web address)

1030 <name>,<uuid>,\:<minor>,<flags>,\:<table>\:[,<table>+]\:[;<name>,<uuid>,\:<minor>,<flags>,<table>\:[,<table>+]]

-.-.

Add a "\&" after "e.g." and "i.e.", or use English words
(man-pages(7)).
Abbreviation points should be protected against being interpreted as
an end of sentence, if they are not, and that independent of the
current place on the line.

581:Note: Same cookie should be used for same type of operations i.e. creation of
767:Attempts to remove all device definitions i.e. reset the driver.  This also runs
946:e.g. striped 2 32 /dev/hda1 0 /dev/hdb1 0

-.-.

Wrong distance between sentences in the input file.

  Separate the sentences and subordinate clauses; each begins on a new
line.  See man-pages(7) ("Conventions for source file layout") and
"info groff" ("Input Conventions").

  The best procedure is to always start a new sentence on a new line,
at least, if you are typing on a computer.

Remember coding: Only one command ("sentence") on each (logical) line.

E-mail: Easier to quote exactly the relevant lines.

Generally: Easier to edit the sentence.

Patches: Less unaffected text.

Search for two adjacent words is easier, when they belong to the same line,
and the same phrase.

  The amount of space between sentences in the output can then be
controlled with the ".ss" request.

Mark a final abbreviation point as such by suffixing it with "\&".

Some sentences (etc.) do not begin on a new line.

Split (sometimes) lines after a punctuation mark; before a conjunction.

N.B.

  The number of lines affected can be too large to be in a patch.

  Lines with only one (or two) space(s) between sentences could be split,
so latter sentences begin on a new line.

440:potential problems.  Useful when debugging scripts.
449:Specify the number of times to repeat a report. Set this to zero
450:continue until interrupted.  The default interval is one second.
470:repeating reports. If \fB\-\-interval\fP is specified but \fB\-\-count\fP
477:processing device-mapper device names and UUIDs. The names and UUIDs
485:Character whitelist: 0\-9, A\-Z, a\-z, #+\-.:=@_. This whitelist is
486:also supported by udev. Any character not on a whitelist is replaced
506:Add a "DM_" prefix plus the field name to the output.  Useful with
553:a suitable value automatically.  The \fB+\fP prefix lets you
564:Process only items that match \fIselection\fP criteria.  If the command is
567:\fIselection\fP and 0 otherwise. The selection criteria are defined by
569:comparison operators. As a quick help and to see full list of column names that
581:Note: Same cookie should be used for same type of operations i.e. creation of
582:multiple different devices. It's not advised to combine different
633:Use a backslash to escape the following character, for example a comma or semi-colon in a name or table. See also CONCISE FORMAT below.
639:device. Device names on output can be customised by following \fIoptions\fP:
691:List device names.  Optionally only list devices that have at least
692:one target of the specified type.  Optionally execute a command for
693:each device.  The device name is appended to the supplied command.
720:a rename if necessary. Any character not on the whitelist will be mangled
721:based on the \fB\-\-manglename\fP setting. Automatic rename works only for device
723:the UUID of active devices. Any incorrect UUIDs are reported only and they
737:Send message to target. If sector not needed use 0.
750:Removes a device.  It will no longer be visible to dmsetup.  Open devices
752:that fails all I/O.  \fB\-\-deferred\fP will enable deferred removal of open
753:devices \- the device will be removed when the last user closes it. The deferred
755:driver available in upstream kernel version 3.13.  (Use \fBdmsetup version\fP
756:to check this.)  If an attempt to remove a device fails, perhaps because a process run
767:Attempts to remove all device definitions i.e. reset the driver.  This also runs
768:\fBmknodes\fP afterwards.  Use with care!  Open devices cannot be removed, but
771:will be removed when the last user closes it.  The deferred removal feature is
821:any is displayed.  With \fB\-\-noflush\fP, the thin target (from version 1.3.0)
827:Suspends a device.  Any I/O that has already been mapped by the device
828:but has not yet completed will be flushed.  Any further I/O to that
833:the \fB\-\-noflush\fP option.  This lets outstanding I/O that has not yet reached the
844:targets unless the \fB\-\-showkeys\fP parameter is supplied. Kernel key
849:and the table (if present). Semi-colons separate devices. Backslashes escape
850:any commas, semi-colons or backslashes.  See CONCISE FORMAT below.
871:List all existing cookies. Cookies are system-wide semaphores with keys
878:The output is a cookie value. Normally we don't need to create cookies since
879:dmsetup creates and destroys them for each action automatically. However, we can
881:cookie instead. We can define a cookie to use for each relevant command by using
882:\fB\-\-udevcookie\fP option. Alternatively, we can export this value into the environment
893:rules. If the flag has its symbolic name assigned then the output is
896:always reported as DM_SUBSYSTEM_UDEV_FLAG<flag_position> = '1'. There are
903:the cookie with underlying semaphore. If the cookie is not given directly,
926:sent to the device.  If successful, this should release any devices
946:e.g. striped 2 32 /dev/hda1 0 /dev/hdb1 0
958:Errors any I/O that goes to this area.  Useful for testing or
962:Returns blocks of zeroes on reads.  Any data written is discarded silently.
976:Delays reads and/or writes to different devices.  Useful for testing.
1044:The minor number of the device.  If empty, the kernel assigns a suitable minor number.
1058:One line of the table. See TABLE FORMAT above.
1088:A default mangling mode. Defaults to "\fBauto\fP"

-.-.

Split lines longer than 80 characters into two or more lines.
Appropriate break points are the end of a sentence and a subordinate
clause; after punctuation marks.
Add "\:" to split the string for the output, "\<newline>" in the source.  

N.B.

  The number of lines affected can be too large to be in a patch.


Line 435, length 85

Ensure \fI/dev/mapper\fP node exists after \fBdmsetup\ resume\fP (default with udev).

Line 617, length 82

If \fItable\fP or \fItable_file\fP is supplied, the table is loaded and made live.

Line 629, length 113

Each device is specified by a comma-separated list: name, uuid, minor number, flags, comma-separated table lines.

Line 633, length 135

Use a backslash to escape the following character, for example a comma or semi-colon in a name or table. See also CONCISE FORMAT below.

Line 642, length 82

\fBdevname\fP (map name for device-mapper devices, equal to blkdevname otherwise).

Line 697, length 82

\fBdevname\fP (map name for device-mapper devices, equal to blkdevname otherwise).

Line 712, length 83

Loads \fItable\fP or \fItable_file\fP into the inactive table slot for device_name.

Line 718, length 82

Ensure existing device-mapper \fIdevice_name\fP and UUID is in the correct mangled

Line 721, length 81

based on the \fB\-\-manglename\fP setting. Automatic rename works only for device

Line 756, length 86

to check this.)  If an attempt to remove a device fails, perhaps because a process run

Line 833, length 85

the \fB\-\-noflush\fP option.  This lets outstanding I/O that has not yet reached the

Line 860, length 89

Wake any processes that are waiting for udev to complete processing the specified cookie.

Line 882, length 89

\fB\-\-udevcookie\fP option. Alternatively, we can export this value into the environment

Line 883, length 89

of the dmsetup process as \fBDM_UDEV_COOKIE\fP variable and it will be used automatically

Line 904, length 89

the command will try to use a value defined by \fBDM_UDEV_COOKIE\fP environment variable.

Line 996, length 82

Supports thin provisioning of devices and also provides a better snapshot support.

Line 1030, length 111

<name>,<uuid>,\:<minor>,<flags>,\:<table>\:[,<table>+]\:[;<name>,<uuid>,\:<minor>,<flags>,<table>\:[,<table>+]]

Line 1044, length 86

The minor number of the device.  If empty, the kernel assigns a suitable minor number.

Line 1067, length 93

test-linear\-small,,,ro,\:0 2097152 linear /dev/loop0 0,\:2097152 2097152 linear /dev/loop1 0

Line 1071, length 148

test-linear\-small,,,,\:0 2097152 linear /dev/loop0 0;\:test-linear\-large,\:,,,\:0 2097152 linear /dev/loop1 0, 2097152 2097152 linear /dev/loop2 0

-.-.

Use \(en (en-dash) for a dash at the beginning (en) of a line,
or between space characters,
not a minus (\-) or a hyphen (-), except in the NAME section.

dmsetup.8:1023:\- A comma separates the fields of each device.
dmsetup.8:1025:\- A semi-colon separates devices.

-.-.

Remove quotes when there is a printable
but no space character between them
and the quotes are not for emphasis (markup),
for example as an argument to a macro.

1:.TH DMSETUP 8 "Apr 06 2006" "Linux" "MAINTENANCE COMMANDS"

-.-.

Output from "test-groff  -mandoc -t -K utf8 -rF0 -rHY=0 -rCHECKSTYLE=10 -ww -z ":

an.tmac:<stdin>:11: style: use of deprecated macro: .PD
an.tmac:<stdin>:18: misuse, warning: .BR is for at least 2 arguments, got 1
	Use macro '.B' for one argument or split argument.
an.tmac:<stdin>:18: misuse, warning: .IR is for at least 2 arguments, got 1
	Use macro '.I' for one argument or split argument.
an.tmac:<stdin>:37: misuse, warning: .BR is for at least 2 arguments, got 1
	Use macro '.B' for one argument or split argument.
an.tmac:<stdin>:37: misuse, warning: .IR is for at least 2 arguments, got 1
	Use macro '.I' for one argument or split argument.
an.tmac:<stdin>:48: misuse, warning: .BR is for at least 2 arguments, got 1
	Use macro '.B' for one argument or split argument.
an.tmac:<stdin>:48: misuse, warning: .BR is for at least 2 arguments, got 1
	Use macro '.B' for one argument or split argument.
an.tmac:<stdin>:60: misuse, warning: .BR is for at least 2 arguments, got 1
	Use macro '.B' for one argument or split argument.
an.tmac:<stdin>:68: misuse, warning: .BR is for at least 2 arguments, got 1
	Use macro '.B' for one argument or split argument.
an.tmac:<stdin>:76: misuse, warning: .BR is for at least 2 arguments, got 1
	Use macro '.B' for one argument or split argument.
an.tmac:<stdin>:101: misuse, warning: .BR is for at least 2 arguments, got 1
	Use macro '.B' for one argument or split argument.
an.tmac:<stdin>:113: misuse, warning: .BR is for at least 2 arguments, got 1
	Use macro '.B' for one argument or split argument.
an.tmac:<stdin>:113: misuse, warning: .IR is for at least 2 arguments, got 1
	Use macro '.I' for one argument or split argument.
an.tmac:<stdin>:131: misuse, warning: .BR is for at least 2 arguments, got 1
	Use macro '.B' for one argument or split argument.
an.tmac:<stdin>:139: misuse, warning: .BR is for at least 2 arguments, got 1
	Use macro '.B' for one argument or split argument.
an.tmac:<stdin>:147: misuse, warning: .BR is for at least 2 arguments, got 1
	Use macro '.B' for one argument or split argument.
an.tmac:<stdin>:157: misuse, warning: .BR is for at least 2 arguments, got 1
	Use macro '.B' for one argument or split argument.
an.tmac:<stdin>:157: misuse, warning: .IR is for at least 2 arguments, got 1
	Use macro '.I' for one argument or split argument.
an.tmac:<stdin>:157: misuse, warning: .IR is for at least 2 arguments, got 1
	Use macro '.I' for one argument or split argument.
an.tmac:<stdin>:157: misuse, warning: .IR is for at least 2 arguments, got 1
	Use macro '.I' for one argument or split argument.
an.tmac:<stdin>:165: misuse, warning: .BR is for at least 2 arguments, got 1
	Use macro '.B' for one argument or split argument.
an.tmac:<stdin>:177: misuse, warning: .BR is for at least 2 arguments, got 1
	Use macro '.B' for one argument or split argument.
an.tmac:<stdin>:177: misuse, warning: .IR is for at least 2 arguments, got 1
	Use macro '.I' for one argument or split argument.
an.tmac:<stdin>:190: misuse, warning: .BR is for at least 2 arguments, got 1
	Use macro '.B' for one argument or split argument.
an.tmac:<stdin>:199: misuse, warning: .BR is for at least 2 arguments, got 1
	Use macro '.B' for one argument or split argument.
an.tmac:<stdin>:208: misuse, warning: .BR is for at least 2 arguments, got 1
	Use macro '.B' for one argument or split argument.
an.tmac:<stdin>:208: misuse, warning: .IR is for at least 2 arguments, got 1
	Use macro '.I' for one argument or split argument.
an.tmac:<stdin>:208: misuse, warning: .IR is for at least 2 arguments, got 1
	Use macro '.I' for one argument or split argument.
an.tmac:<stdin>:218: misuse, warning: .BR is for at least 2 arguments, got 1
	Use macro '.B' for one argument or split argument.
an.tmac:<stdin>:218: misuse, warning: .IR is for at least 2 arguments, got 1
	Use macro '.I' for one argument or split argument.
an.tmac:<stdin>:218: misuse, warning: .BR is for at least 2 arguments, got 1
	Use macro '.B' for one argument or split argument.
an.tmac:<stdin>:218: misuse, warning: .IR is for at least 2 arguments, got 1
	Use macro '.I' for one argument or split argument.
an.tmac:<stdin>:233: misuse, warning: .BR is for at least 2 arguments, got 1
	Use macro '.B' for one argument or split argument.
an.tmac:<stdin>:249: misuse, warning: .BR is for at least 2 arguments, got 1
	Use macro '.B' for one argument or split argument.
an.tmac:<stdin>:249: misuse, warning: .IR is for at least 2 arguments, got 1
	Use macro '.I' for one argument or split argument.
an.tmac:<stdin>:249: misuse, warning: .IR is for at least 2 arguments, got 1
	Use macro '.I' for one argument or split argument.
an.tmac:<stdin>:249: misuse, warning: .IR is for at least 2 arguments, got 1
	Use macro '.I' for one argument or split argument.
an.tmac:<stdin>:249: misuse, warning: .IR is for at least 2 arguments, got 1
	Use macro '.I' for one argument or split argument.
an.tmac:<stdin>:249: misuse, warning: .IR is for at least 2 arguments, got 1
	Use macro '.I' for one argument or split argument.
an.tmac:<stdin>:258: misuse, warning: .BR is for at least 2 arguments, got 1
	Use macro '.B' for one argument or split argument.
an.tmac:<stdin>:258: misuse, warning: .IR is for at least 2 arguments, got 1
	Use macro '.I' for one argument or split argument.
an.tmac:<stdin>:267: misuse, warning: .BR is for at least 2 arguments, got 1
	Use macro '.B' for one argument or split argument.
an.tmac:<stdin>:267: misuse, warning: .IR is for at least 2 arguments, got 1
	Use macro '.I' for one argument or split argument.
an.tmac:<stdin>:280: misuse, warning: .BR is for at least 2 arguments, got 1
	Use macro '.B' for one argument or split argument.
an.tmac:<stdin>:294: misuse, warning: .BR is for at least 2 arguments, got 1
	Use macro '.B' for one argument or split argument.
an.tmac:<stdin>:310: misuse, warning: .BR is for at least 2 arguments, got 1
	Use macro '.B' for one argument or split argument.
an.tmac:<stdin>:317: misuse, warning: .BR is for at least 2 arguments, got 1
	Use macro '.B' for one argument or split argument.
an.tmac:<stdin>:325: misuse, warning: .BR is for at least 2 arguments, got 1
	Use macro '.B' for one argument or split argument.
an.tmac:<stdin>:325: misuse, warning: .IR is for at least 2 arguments, got 1
	Use macro '.I' for one argument or split argument.
an.tmac:<stdin>:333: misuse, warning: .BR is for at least 2 arguments, got 1
	Use macro '.B' for one argument or split argument.
an.tmac:<stdin>:340: misuse, warning: .BR is for at least 2 arguments, got 1
	Use macro '.B' for one argument or split argument.
an.tmac:<stdin>:347: misuse, warning: .BR is for at least 2 arguments, got 1
	Use macro '.B' for one argument or split argument.
an.tmac:<stdin>:355: misuse, warning: .BR is for at least 2 arguments, got 1
	Use macro '.B' for one argument or split argument.
an.tmac:<stdin>:355: misuse, warning: .IR is for at least 2 arguments, got 1
	Use macro '.I' for one argument or split argument.
an.tmac:<stdin>:363: misuse, warning: .BR is for at least 2 arguments, got 1
	Use macro '.B' for one argument or split argument.
an.tmac:<stdin>:370: misuse, warning: .BR is for at least 2 arguments, got 1
	Use macro '.B' for one argument or split argument.
an.tmac:<stdin>:384: misuse, warning: .BR is for at least 2 arguments, got 1
	Use macro '.B' for one argument or split argument.
an.tmac:<stdin>:384: misuse, warning: .IR is for at least 2 arguments, got 1
	Use macro '.I' for one argument or split argument.
an.tmac:<stdin>:399: misuse, warning: .BR is for at least 2 arguments, got 1
	Use macro '.B' for one argument or split argument.
an.tmac:<stdin>:408: style: use of deprecated macro: .PD
an.tmac:<stdin>:609: misuse, warning: .BR is for at least 2 arguments, got 1
	Use macro '.B' for one argument or split argument.
an.tmac:<stdin>:609: misuse, warning: .IR is for at least 2 arguments, got 1
	Use macro '.I' for one argument or split argument.
an.tmac:<stdin>:614: misuse, warning: .BR is for at least 2 arguments, got 1
	Use macro '.B' for one argument or split argument.
an.tmac:<stdin>:614: misuse, warning: .IR is for at least 2 arguments, got 1
	Use macro '.I' for one argument or split argument.
an.tmac:<stdin>:626: misuse, warning: .BR is for at least 2 arguments, got 1
	Use macro '.B' for one argument or split argument.
an.tmac:<stdin>:626: misuse, warning: .BR is for at least 2 arguments, got 1
	Use macro '.B' for one argument or split argument.
an.tmac:<stdin>:636: misuse, warning: .BR is for at least 2 arguments, got 1
	Use macro '.B' for one argument or split argument.
an.tmac:<stdin>:645: misuse, warning: .BR is for at least 2 arguments, got 1
	Use macro '.B' for one argument or split argument.
an.tmac:<stdin>:651: misuse, warning: .BR is for at least 2 arguments, got 1
	Use macro '.B' for one argument or split argument.
an.tmac:<stdin>:656: style: 1 leading space(s) on input line
an.tmac:<stdin>:657: style: 1 leading space(s) on input line
an.tmac:<stdin>:658: style: 1 leading space(s) on input line
an.tmac:<stdin>:659: style: 1 leading space(s) on input line
an.tmac:<stdin>:660: style: 1 leading space(s) on input line
an.tmac:<stdin>:661: style: 1 leading space(s) on input line
an.tmac:<stdin>:662: style: 1 leading space(s) on input line
an.tmac:<stdin>:666: misuse, warning: .BR is for at least 2 arguments, got 1
	Use macro '.B' for one argument or split argument.
an.tmac:<stdin>:689: misuse, warning: .BR is for at least 2 arguments, got 1
	Use macro '.B' for one argument or split argument.
an.tmac:<stdin>:710: misuse, warning: .BR is for at least 2 arguments, got 1
	Use macro '.B' for one argument or split argument.
an.tmac:<stdin>:710: misuse, warning: .IR is for at least 2 arguments, got 1
	Use macro '.I' for one argument or split argument.
an.tmac:<stdin>:716: misuse, warning: .BR is for at least 2 arguments, got 1
	Use macro '.B' for one argument or split argument.
an.tmac:<stdin>:728: misuse, warning: .BR is for at least 2 arguments, got 1
	Use macro '.B' for one argument or split argument.
an.tmac:<stdin>:735: misuse, warning: .BR is for at least 2 arguments, got 1
	Use macro '.B' for one argument or split argument.
an.tmac:<stdin>:735: misuse, warning: .IR is for at least 2 arguments, got 1
	Use macro '.I' for one argument or split argument.
an.tmac:<stdin>:735: misuse, warning: .IR is for at least 2 arguments, got 1
	Use macro '.I' for one argument or split argument.
an.tmac:<stdin>:735: misuse, warning: .IR is for at least 2 arguments, got 1
	Use macro '.I' for one argument or split argument.
an.tmac:<stdin>:740: misuse, warning: .BR is for at least 2 arguments, got 1
	Use macro '.B' for one argument or split argument.
an.tmac:<stdin>:748: misuse, warning: .BR is for at least 2 arguments, got 1
	Use macro '.B' for one argument or split argument.
an.tmac:<stdin>:765: misuse, warning: .BR is for at least 2 arguments, got 1
	Use macro '.B' for one argument or split argument.
an.tmac:<stdin>:776: misuse, warning: .BR is for at least 2 arguments, got 1
	Use macro '.B' for one argument or split argument.
an.tmac:<stdin>:776: misuse, warning: .IR is for at least 2 arguments, got 1
	Use macro '.I' for one argument or split argument.
an.tmac:<stdin>:776: misuse, warning: .IR is for at least 2 arguments, got 1
	Use macro '.I' for one argument or split argument.
an.tmac:<stdin>:781: misuse, warning: .BR is for at least 2 arguments, got 1
	Use macro '.B' for one argument or split argument.
an.tmac:<stdin>:781: misuse, warning: .IR is for at least 2 arguments, got 1
	Use macro '.I' for one argument or split argument.
an.tmac:<stdin>:781: misuse, warning: .BR is for at least 2 arguments, got 1
	Use macro '.B' for one argument or split argument.
an.tmac:<stdin>:781: misuse, warning: .IR is for at least 2 arguments, got 1
	Use macro '.I' for one argument or split argument.
an.tmac:<stdin>:787: misuse, warning: .BR is for at least 2 arguments, got 1
	Use macro '.B' for one argument or split argument.
an.tmac:<stdin>:794: misuse, warning: .BR is for at least 2 arguments, got 1
	Use macro '.B' for one argument or split argument.
an.tmac:<stdin>:794: misuse, warning: .IR is for at least 2 arguments, got 1
	Use macro '.I' for one argument or split argument.
an.tmac:<stdin>:794: misuse, warning: .IR is for at least 2 arguments, got 1
	Use macro '.I' for one argument or split argument.
an.tmac:<stdin>:794: misuse, warning: .IR is for at least 2 arguments, got 1
	Use macro '.I' for one argument or split argument.
an.tmac:<stdin>:794: misuse, warning: .IR is for at least 2 arguments, got 1
	Use macro '.I' for one argument or split argument.
an.tmac:<stdin>:794: misuse, warning: .IR is for at least 2 arguments, got 1
	Use macro '.I' for one argument or split argument.
an.tmac:<stdin>:799: misuse, warning: .BR is for at least 2 arguments, got 1
	Use macro '.B' for one argument or split argument.
an.tmac:<stdin>:799: misuse, warning: .IR is for at least 2 arguments, got 1
	Use macro '.I' for one argument or split argument.
an.tmac:<stdin>:810: misuse, warning: .BR is for at least 2 arguments, got 1
	Use macro '.B' for one argument or split argument.
an.tmac:<stdin>:810: misuse, warning: .IR is for at least 2 arguments, got 1
	Use macro '.I' for one argument or split argument.
an.tmac:<stdin>:817: misuse, warning: .BR is for at least 2 arguments, got 1
	Use macro '.B' for one argument or split argument.
an.tmac:<stdin>:825: misuse, warning: .BR is for at least 2 arguments, got 1
	Use macro '.B' for one argument or split argument.
an.tmac:<stdin>:837: misuse, warning: .BR is for at least 2 arguments, got 1
	Use macro '.B' for one argument or split argument.
an.tmac:<stdin>:853: misuse, warning: .BR is for at least 2 arguments, got 1
	Use macro '.B' for one argument or split argument.
an.tmac:<stdin>:858: misuse, warning: .BR is for at least 2 arguments, got 1
	Use macro '.B' for one argument or split argument.
an.tmac:<stdin>:858: misuse, warning: .IR is for at least 2 arguments, got 1
	Use macro '.I' for one argument or split argument.
an.tmac:<stdin>:863: misuse, warning: .BR is for at least 2 arguments, got 1
	Use macro '.B' for one argument or split argument.
an.tmac:<stdin>:869: misuse, warning: .BR is for at least 2 arguments, got 1
	Use macro '.B' for one argument or split argument.
an.tmac:<stdin>:875: misuse, warning: .BR is for at least 2 arguments, got 1
	Use macro '.B' for one argument or split argument.
an.tmac:<stdin>:889: misuse, warning: .BR is for at least 2 arguments, got 1
	Use macro '.B' for one argument or split argument.
an.tmac:<stdin>:889: misuse, warning: .IR is for at least 2 arguments, got 1
	Use macro '.I' for one argument or split argument.
an.tmac:<stdin>:900: misuse, warning: .BR is for at least 2 arguments, got 1
	Use macro '.B' for one argument or split argument.
an.tmac:<stdin>:907: misuse, warning: .BR is for at least 2 arguments, got 1
	Use macro '.B' for one argument or split argument.
an.tmac:<stdin>:912: misuse, warning: .BR is for at least 2 arguments, got 1
	Use macro '.B' for one argument or split argument.
an.tmac:<stdin>:912: misuse, warning: .IR is for at least 2 arguments, got 1
	Use macro '.I' for one argument or split argument.
an.tmac:<stdin>:922: misuse, warning: .BR is for at least 2 arguments, got 1
	Use macro '.B' for one argument or split argument.
an.tmac:<stdin>:950: style: 1 leading space(s) on input line
an.tmac:<stdin>:951: style: 1 leading space(s) on input line
an.tmac:<stdin>:952: style: 1 leading space(s) on input line
an.tmac:<stdin>:953: style: 1 leading space(s) on input line
an.tmac:<stdin>:954: style: 1 leading space(s) on input line
an.tmac:<stdin>:1062: style: use of deprecated macro: .PD
an.tmac:<stdin>:1074: style: use of deprecated macro: .PD

-.-.

Generally:

Split (sometimes) lines after a punctuation mark; before a conjunction.

--pc6zmQobCfgffrNE
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="dmsetup.8.diff"

--- dmsetup.8	2025-02-22 09:36:37.495665268 +0000
+++ dmsetup.8.new	2025-02-22 11:03:47.574613770 +0000
@@ -1,4 +1,4 @@
-.TH DMSETUP 8 "Apr 06 2006" "Linux" "MAINTENANCE COMMANDS"
+.TH DMSETUP 8 "Apr 06 2006" Linux "MAINTENANCE COMMANDS"
 .
 .SH NAME
 .
@@ -12,8 +12,8 @@ dmsetup \(em low level logical volume ma
 .HP 9
 .B dmsetup
 .de CMD_CLEAR
-.  BR clear
-.  IR device_name
+.  B clear
+.  I device_name
 ..
 .CMD_CLEAR
 .
@@ -22,8 +22,8 @@ dmsetup \(em low level logical volume ma
 .de CMD_CREATE
 .  ad l
 .  nh
-.  BR create
-.  IR device_name
+.  B create
+.  I device_name
 .  RB [ \-n | \-\-notable |\: \-\-table
 .  IR table |\: table_file ]
 .  RB [ \-\-readahead
@@ -40,8 +40,8 @@ dmsetup \(em low level logical volume ma
 .B dmsetup
 .de CMD_CREATE_CONCISE
 .  ad l
-.  BR create
-.  BR \-\-concise
+.  B create
+.  B \-\-concise
 .  RI [ concise_device_specification ]
 .  ad b
 ..
@@ -51,7 +51,7 @@ dmsetup \(em low level logical volume ma
 .B dmsetup
 .de CMD_DEPS
 .  ad l
-.  BR deps
+.  B deps
 .  RB [ \-o
 .  IR options ]
 .  RI [ device_name ...]
@@ -62,7 +62,7 @@ dmsetup \(em low level logical volume ma
 .HP
 .B dmsetup
 .de CMD_HELP
-.  BR help
+.  B help
 .  RB [ \-c | \-C | \-\-columns ]
 ..
 .CMD_HELP
@@ -70,7 +70,7 @@ dmsetup \(em low level logical volume ma
 .HP
 .B dmsetup
 .de CMD_INFO
-.  BR info
+.  B info
 .  RI [ device_name ...]
 ..
 .CMD_INFO
@@ -80,7 +80,7 @@ dmsetup \(em low level logical volume ma
 .de CMD_INFOLONG
 .  ad l
 .  nh
-.  BR info
+.  B info
 .  BR \-c | \-C | \-\-columns
 .  RB [ \-\-count
 .  IR count ]
@@ -104,8 +104,8 @@ dmsetup \(em low level logical volume ma
 .B dmsetup
 .de CMD_LOAD
 .  ad l
-.  BR load
-.  IR device_name
+.  B load
+.  I device_name
 .  RB [ \-\-table
 .  IR table | table_file ]
 .  ad b
@@ -117,7 +117,7 @@ dmsetup \(em low level logical volume ma
 .de CMD_LS
 .  ad l
 .  nh
-.  BR ls
+.  B ls
 .  RB [ \-\-target
 .  IR target_type ]
 .  RB [ \-o
@@ -133,7 +133,7 @@ dmsetup \(em low level logical volume ma
 .HP
 .B dmsetup
 .de CMD_MANGLE
-.  BR mangle
+.  B mangle
 .  RI [ device_name ...]
 ..
 .CMD_MANGLE
@@ -141,7 +141,7 @@ dmsetup \(em low level logical volume ma
 .HP
 .B dmsetup
 .de CMD_MEASURE
-.  BR measure
+.  B measure
 .  RI [ device_name ...]
 ..
 .CMD_MEASURE
@@ -149,17 +149,17 @@ dmsetup \(em low level logical volume ma
 .HP
 .B dmsetup
 .de CMD_MESSAGE
-.  BR message
-.  IR device_name
-.  IR sector
-.  IR message
+.  B message
+.  I device_name
+.  I sector
+.  I message
 ..
 .CMD_MESSAGE
 .
 .HP
 .B dmsetup
 .de CMD_MKNODES
-.  BR mknodes
+.  B mknodes
 .  RI [ device_name ...]
 ..
 .CMD_MKNODES
@@ -168,8 +168,8 @@ dmsetup \(em low level logical volume ma
 .B dmsetup
 .de CMD_RELOAD
 .  ad l
-.  BR reload
-.  IR device_name
+.  B reload
+.  I device_name
 .  RB [ \-\-table
 .  IR table | table_file ]
 .  ad b
@@ -180,7 +180,7 @@ dmsetup \(em low level logical volume ma
 .B dmsetup
 .de CMD_REMOVE
 .  ad l
-.  BR remove
+.  B remove
 .  RB [ \-f | \-\-force ]
 .  RB [ \-\-retry ]
 .  RB [ \-\-deferred ]
@@ -192,7 +192,7 @@ dmsetup \(em low level logical volume ma
 .HP
 .B dmsetup
 .de CMD_REMOVE_ALL
-.  BR remove_all
+.  B remove_all
 .  RB [ \-f | \-\-force ]
 .  RB [ \-\-deferred ]
 ..
@@ -201,19 +201,19 @@ dmsetup \(em low level logical volume ma
 .HP
 .B dmsetup
 .de CMD_RENAME
-.  BR rename
-.  IR device_name
-.  IR new_name
+.  B rename
+.  I device_name
+.  I new_name
 ..
 .CMD_RENAME
 .
 .HP
 .B dmsetup
 .de CMD_RENAME_UUID
-.  BR rename
-.  IR device_name
-.  BR \-\-setuuid
-.  IR uuid
+.  B rename
+.  I device_name
+.  B \-\-setuuid
+.  I uuid
 ..
 .CMD_RENAME_UUID
 .
@@ -221,7 +221,7 @@ dmsetup \(em low level logical volume ma
 .B dmsetup
 .de CMD_RESUME
 .  ad l
-.  BR resume
+.  B resume
 .  IR device_name ...
 .  RB [ \-\-addnodeoncreate | \-\-addnodeonresume ]
 .  RB [ \-\-noflush ]
@@ -237,12 +237,12 @@ dmsetup \(em low level logical volume ma
 .de CMD_SETGEOMETRY
 .  ad l
 .  nh
-.  BR setgeometry
-.  IR device_name
-.  IR cyl
-.  IR head
-.  IR sect
-.  IR start
+.  B setgeometry
+.  I device_name
+.  I cyl
+.  I head
+.  I sect
+.  I start
 .  hy
 .  ad b
 ..
@@ -251,8 +251,8 @@ dmsetup \(em low level logical volume ma
 .HP
 .B dmsetup
 .de CMD_SPLITNAME
-.  BR splitname
-.  IR device_name
+.  B splitname
+.  I device_name
 .  RI [ subsystem ]
 ..
 .CMD_SPLITNAME
@@ -260,8 +260,8 @@ dmsetup \(em low level logical volume ma
 .HP
 .B dmsetup
 .de CMD_STATS
-.  BR stats
-.  IR command
+.  B stats
+.  I command
 .  RI [ options ]
 ..
 .CMD_STATS
@@ -270,7 +270,7 @@ dmsetup \(em low level logical volume ma
 .B dmsetup
 .de CMD_STATUS
 .  ad l
-.  BR status
+.  B status
 .  RB [ \-\-target
 .  IR target_type ]
 .  RB [ \-\-noflush ]
@@ -284,7 +284,7 @@ dmsetup \(em low level logical volume ma
 .de CMD_SUSPEND
 .  ad l
 .  nh
-.  BR suspend
+.  B suspend
 .  RB [ \-\-nolockfs ]
 .  RB [ \-\-noflush ]
 .  IR device_name ...
@@ -298,7 +298,7 @@ dmsetup \(em low level logical volume ma
 .de CMD_TABLE
 .  ad l
 .  nh
-.  BR table
+.  B table
 .  RB [ \-\-concise ]
 .  RB [ \-\-target
 .  IR target_type ]
@@ -312,22 +312,22 @@ dmsetup \(em low level logical volume ma
 .HP
 .B dmsetup
 .de CMD_TARGETS
-.  BR targets
+.  B targets
 ..
 .CMD_TARGETS
 .
 .HP
 .B dmsetup
 .de CMD_UDEVCOMPLETE
-.  BR udevcomplete
-.  IR cookie
+.  B udevcomplete
+.  I cookie
 ..
 .CMD_UDEVCOMPLETE
 .
 .HP
 .B dmsetup
 .de CMD_UDEVCOMPLETE_ALL
-.  BR udevcomplete_all
+.  B udevcomplete_all
 .  RI [ age_in_minutes ]
 ..
 .CMD_UDEVCOMPLETE_ALL
@@ -335,29 +335,29 @@ dmsetup \(em low level logical volume ma
 .HP
 .B dmsetup
 .de CMD_UDEVCOOKIES
-.  BR udevcookie
+.  B udevcookie
 ..
 .CMD_UDEVCOOKIES
 .
 .HP
 .B dmsetup
 .de CMD_UDEVCREATECOOKIE
-.  BR udevcreatecookie
+.  B udevcreatecookie
 ..
 .CMD_UDEVCREATECOOKIE
 .
 .HP
 .B dmsetup
 .de CMD_UDEVFLAGS
-.  BR udevflags
-.  IR cookie
+.  B udevflags
+.  I cookie
 ..
 .CMD_UDEVFLAGS
 .
 .HP
 .B dmsetup
 .de CMD_UDEVRELEASECOOKIE
-.  BR udevreleasecookie
+.  B udevreleasecookie
 .  RI [ cookie ]
 ..
 .CMD_UDEVRELEASECOOKIE
@@ -365,7 +365,7 @@ dmsetup \(em low level logical volume ma
 .HP
 .B dmsetup
 .de CMD_VERSION
-.  BR version
+.  B version
 ..
 .CMD_VERSION
 .
@@ -374,9 +374,9 @@ dmsetup \(em low level logical volume ma
 .de CMD_WAIT
 .  ad l
 .  nh
-.  BR wait
+.  B wait
 .  RB [ \-\-noflush ]
-.  IR device_name
+.  I device_name
 .  RI [ event_nr ]
 .  hy
 .  ad b
@@ -388,7 +388,7 @@ dmsetup \(em low level logical volume ma
 .de CMD_WIPE_TABLE
 .  ad l
 .  nh
-.  BR wipe_table
+.  B wipe_table
 .  IR device_name ...
 .  RB [ \-f | \-\-force ]
 .  RB [ \-\-noflush ]
@@ -420,8 +420,7 @@ The second argument is the logical devic
 Invoking the dmsetup tool as \fBdevmap_name\fP
 (which is not normally distributed and is supported
 only for historical reasons) is equivalent to
-.BI \%dmsetup\ info\ \-c\ \-\-noheadings\ \-j \ major\  \-m \ minor \c
-\fR.
+.BI \%dmsetup\ info\ \-c\ \-\-noheadings\ \-j \ major\  \-m \ minor\fR.
 .\" dot above here fixes \-Thtml rendering for next HP option
 .
 .SH OPTIONS
@@ -432,7 +431,8 @@ Ensure \fI/dev/mapper\fP node exists aft
 .
 .TP
 .B \-\-addnodeonresume
-Ensure \fI/dev/mapper\fP node exists after \fBdmsetup\ resume\fP (default with udev).
+Ensure \fI/dev/mapper\fP node exists after \fBdmsetup\ resume\fP
+(default with udev).
 .
 .TP
 .B \-\-checks
@@ -482,9 +482,9 @@ if already mangled, error on mixed),
 \fBhex\fP (always do the mangling) and
 \fBnone\fP (no mangling).
 Default mode is \fBauto\fP.
-Character whitelist: 0\-9, A\-Z, a\-z, #+\-.:=@_. This whitelist is
+Character whitelist: 0\(en9, A\(enZ, a\(enz, #+\-.:=@_. This whitelist is
 also supported by udev. Any character not on a whitelist is replaced
-with its hex value (two digits) prefixed by \\x.
+with its hex value (two digits) prefixed by \ex.
 Mangling mode could be also set through
 \fBDM_DEFAULT_NAME_MANGLING_MODE\fP
 environment variable.
@@ -578,7 +578,7 @@ See below for more information on the ta
 .TP
 .B \-\-udevcookie \fIcookie
 Use cookie for udev synchronization.
-Note: Same cookie should be used for same type of operations i.e. creation of
+Note: Same cookie should be used for same type of operations i.e.\& creation of
 multiple different devices. It's not advised to combine different
 operations on the single device.
 .
@@ -614,7 +614,8 @@ Destroys the table in the inactive table
 .CMD_CREATE
 .br
 Creates a device with the given name.
-If \fItable\fP or \fItable_file\fP is supplied, the table is loaded and made live.
+If \fItable\fP or \fItable_file\fP is supplied,
+the table is loaded and made live.
 Otherwise a table is read from standard input unless \fB\-\-notable\fP is used.
 The optional \fIuuid\fP can be used in place of
 device_name in subsequent dmsetup commands.
@@ -626,11 +627,14 @@ See below for more information on the ta
 .CMD_CREATE_CONCISE
 .br
 Creates one or more devices from a concise device specification.
-Each device is specified by a comma-separated list: name, uuid, minor number, flags, comma-separated table lines.
+Each device is specified by a comma-separated list:
+name, uuid, minor number, flags, comma-separated table lines.
 Flags defaults to read-write (rw) or may be read-only (ro).
 Uuid, minor number and flags are optional so those fields may be empty.
 A semi-colon separates specifications of different devices.
-Use a backslash to escape the following character, for example a comma or semi-colon in a name or table. See also CONCISE FORMAT below.
+Use a backslash to escape the following character,
+for example a comma or semi-colon in a name or table.
+See also CONCISE FORMAT below.
 .
 .HP
 .CMD_DEPS
@@ -709,16 +713,19 @@ Others specify how the tree is displayed
 .BR load | \c
 .CMD_RELOAD
 .br
-Loads \fItable\fP or \fItable_file\fP into the inactive table slot for device_name.
+Loads \fItable\fP
+or \fItable_file\fP into the inactive table slot for device_name.
 If neither is supplied, reads a table from standard input.
 .
 .HP
 .CMD_MANGLE
 .br
-Ensure existing device-mapper \fIdevice_name\fP and UUID is in the correct mangled
+Ensure existing device-mapper \fIdevice_name\fP and UUID is in the
+correct mangled
 form containing only whitelisted characters (supported by udev) and do
 a rename if necessary. Any character not on the whitelist will be mangled
-based on the \fB\-\-manglename\fP setting. Automatic rename works only for device
+based on the \fB\-\-manglename\fP setting.
+Automatic rename works only for device
 names and not for device UUIDs because the kernel does not allow changing
 the UUID of active devices. Any incorrect UUIDs are reported only and they
 must be manually corrected by deactivating the device first and then
@@ -753,7 +760,8 @@ that fails all I/O.  \fB\-\-deferred\fP
 devices \- the device will be removed when the last user closes it. The deferred
 removal feature is supported since version 4.27.0 of the device-mapper
 driver available in upstream kernel version 3.13.  (Use \fBdmsetup version\fP
-to check this.)  If an attempt to remove a device fails, perhaps because a process run
+to check this.)
+If an attempt to remove a device fails, perhaps because a process run
 from a quick udev rule temporarily opened the device, the \fB\-\-retry\fP
 option will cause the operation to be retried for a few seconds before failing.
 Do NOT combine
@@ -764,7 +772,8 @@ result.
 .HP
 .CMD_REMOVE_ALL
 .br
-Attempts to remove all device definitions i.e. reset the driver.  This also runs
+Attempts to remove all device definitions i.e.\& reset the driver.
+This also runs
 \fBmknodes\fP afterwards.  Use with care!  Open devices cannot be removed, but
 adding \fB\-\-force\fP will replace the table with one that fails all I/O.
 \fB\-\-deferred\fP will enable deferred removal of open devices \- the device
@@ -830,7 +839,8 @@ device will be postponed for as long as
 If there's a filesystem on the device which supports the operation,
 an attempt will be made to sync it first unless \fB\-\-nolockfs\fP is specified.
 Some targets such as recent (October 2006) versions of multipath may support
-the \fB\-\-noflush\fP option.  This lets outstanding I/O that has not yet reached the
+the \fB\-\-noflush\fP option.
+This lets outstanding I/O that has not yet reached the
 device to remain unflushed.
 .
 .HP
@@ -857,7 +867,8 @@ Displays the names and versions of the c
 .HP
 .CMD_UDEVCOMPLETE
 .br
-Wake any processes that are waiting for udev to complete processing the specified cookie.
+Wake any processes
+that are waiting for udev to complete processing the specified cookie.
 .
 .HP
 .CMD_UDEVCOMPLETE_ALL
@@ -879,8 +890,10 @@ The output is a cookie value. Normally w
 dmsetup creates and destroys them for each action automatically. However, we can
 generate one explicitly to group several actions together and use only one
 cookie instead. We can define a cookie to use for each relevant command by using
-\fB\-\-udevcookie\fP option. Alternatively, we can export this value into the environment
-of the dmsetup process as \fBDM_UDEV_COOKIE\fP variable and it will be used automatically
+\fB\-\-udevcookie\fP option.
+Alternatively, we can export this value into the environment
+of the dmsetup process as \fBDM_UDEV_COOKIE\fP variable
+and it will be used automatically
 with all subsequent commands until it is unset.
 Invoking this command will create system-wide semaphore that needs to be cleaned
 up explicitly by calling udevreleasecookie command.
@@ -901,7 +914,8 @@ always reported as DM_SUBSYSTEM_UDEV_FLA
 .br
 Waits for all pending udev processing bound to given cookie value and clean up
 the cookie with underlying semaphore. If the cookie is not given directly,
-the command will try to use a value defined by \fBDM_UDEV_COOKIE\fP environment variable.
+the command will try to use a value defined by \fBDM_UDEV_COOKIE\fP
+environment variable.
 .
 .HP
 .CMD_VERSION
@@ -943,8 +957,8 @@ The traditional linear mapping.
 .B striped \fInum_stripes chunk_size \fR[\fIdestination start_sector\fR]...
 Creates a striped area.
 .br
-e.g. striped 2 32 /dev/hda1 0 /dev/hdb1 0
-will map the first chunk (16k) as follows:
+e.g.\& striped 2 32 /dev/hda1 0 /dev/hdb1 0
+will map the first chunk (16\~KiB) as follows:
 .RS
 .IP
  LV chunk 1 \[->] hda1, chunk 1
@@ -993,7 +1007,8 @@ Offers an interface to the kernel's soft
 Supports snapshots of devices.
 .TP
 .BR thin ", " thin\-pool
-Supports thin provisioning of devices and also provides a better snapshot support.
+Supports thin provisioning of devices
+and also provides a better snapshot support.
 .P
 To find out more about the various targets and their table formats and status
 lines, please read the files in the Documentation/device-mapper directory in
@@ -1019,10 +1034,9 @@ documentation directory for the device-m
 .
 A concise representation of one of more devices.
 .sp
+\(en A comma separates the fields of each device.
 .br
-\- A comma separates the fields of each device.
-.br
-\- A semi-colon separates devices.
+\(en A semi-colon separates devices.
 .TP
 The representation of a device takes the form:
 .ad l
@@ -1041,7 +1055,8 @@ The name of the device.
 The UUID of the device (or empty).
 .TP
 .B minor
-The minor number of the device.  If empty, the kernel assigns a suitable minor number.
+The minor number of the device.
+If empty, the kernel assigns a suitable minor number.
 .TP
 .B flags
 Supported flags are:
@@ -1064,11 +1079,14 @@ One line of the table. See TABLE FORMAT
 .nh
 # A simple linear read-only device
 .TP
-test-linear\-small,,,ro,\:0 2097152 linear /dev/loop0 0,\:2097152 2097152 linear /dev/loop1 0
+test-linear\-small,,,ro,\:0 2097152 linear /dev/loop0 0,\:2097152 2097152 \
+linear /dev/loop1 0
 .P
 # Two linear devices
 .TP
-test-linear\-small,,,,\:0 2097152 linear /dev/loop0 0;\:test-linear\-large,\:,,,\:0 2097152 linear /dev/loop1 0, 2097152 2097152 linear /dev/loop2 0
+test-linear\-small,,,,\:0 2097152 linear /dev/loop0 \
+0;\:test-linear\-large,\:,,,\:0 2097152 linear /dev/loop1 0, 2097152 \
+2097152 linear /dev/loop2 0
 .hy
 .ad b
 .PD

--pc6zmQobCfgffrNE
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="general.bugs"

  Any program (person), that produces man pages, should check the output
for defects by using (both groff and nroff)

[gn]roff -mandoc -t -ww -b -z -K utf8 <man page>

  The same goes for man pages that are used as an input.

  For a style guide use

  mandoc -T lint

-.-

  Any "autogenerator" should check its products with the above mentioned
'groff', 'mandoc', and additionally with 'nroff ...'.

  It should also check its input files for too long (> 80) lines.

  This is just a simple quality control measure.

  The "autogenerator" may have to be corrected to get a better man page,
the source file may, and any additional file may.

  Common defects:

  Not removing trailing spaces (in in- and output).
  The reason for these trailing spaces should be found and eliminated.

  "git" has a "tool" to point out whitespace,
see for example "git-apply(1)" and git-config(1)")

  Not beginning each input sentence on a new line.
Line length and patch size should thus be reduced.

  The script "reportbug" uses 'quoted-printable' encoding when a line is
longer than 1024 characters in an 'ascii' file.

  See man-pages(7), item "semantic newline".

-.-

The difference between the formatted output of the original and patched file
can be seen with:

  nroff -mandoc <file1> > <out1>
  nroff -mandoc <file2> > <out2>
  diff -d -u <out1> <out2>

and for groff, using

\"printf '%s\n%s\n' '.kern 0' '.ss 12 0' | groff -mandoc -Z - \"

instead of 'nroff -mandoc'

  Add the option '-t', if the file contains a table.

  Read the output from 'diff -d -u ...' with 'less -R' or similar.

-.-.

  If 'man' (man-db) is used to check the manual for warnings,
the following must be set:

  The option \"-warnings=w\"

  The environmental variable:

export MAN_KEEP_STDERR=yes (or any non-empty value)

  or

  (produce only warnings):

export MANROFFOPT=\"-ww -b -z\"

export MAN_KEEP_STDERR=yes (or any non-empty value)

-.-

--pc6zmQobCfgffrNE--
