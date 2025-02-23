Received: from smtp-out1-03.simnet.is (smtp-out1-03.simnet.is [194.105.232.31])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4FD0118D
	for <lvm-devel@lists.linux.dev>; Sun, 23 Feb 2025 00:46:38 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=194.105.232.31
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1740271603; cv=none; b=Ncpb4b7z8TQgX/WRsi07tbFmYQBF0hbxep7Hx3jN1uVaMFBI20aKFOQ824Fov/ovWpKE59jseqmn4XyK54mEDG/PMkSmicfvOiJ/hGIjS3lKvpkk32WaCUTW8XyNQeOkNwgoz+VeTEe0DP4F/4V728cXEPjDD+OxR40/1qEbcSA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1740271603; c=relaxed/simple;
	bh=Sj1rDm/E71OULLDnVP9mmIzDcQLY/ys9xJGhyji5/F4=;
	h=Date:From:To:Cc:Subject:Message-ID:MIME-Version:Content-Type:
	 Content-Disposition; b=gJtDfdMo6zOg0K3N2rzKiEUm7nST7P3TsoFPf495SyJwbcU52tBggixz6j5soNhb3BQtjicS5l2FzFX0aSVhemSuElRFBrzLYsjiI/Q6kAOLZtDgyYkwEGkk+8SiKp1BgLkFzZqzotOKX0tRpiU4ug9b0TdMN8DFVOg+cyNATr4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=simnet.is; spf=pass smtp.mailfrom=simnet.is; dkim=pass (2048-bit key) header.d=simnet.is header.i=@simnet.is header.b=OVDuODUE; arc=none smtp.client-ip=194.105.232.31
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=simnet.is
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=simnet.is
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=simnet.is header.i=@simnet.is header.b="OVDuODUE"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
  d=simnet.is; i=@simnet.is; q=dns/txt; s=sel1;
  t=1740271599; x=1771807599;
  h=date:from:to:cc:subject:message-id:mime-version;
  bh=c734S4XxM7EKy1utff6AF7xMmVTQhDtezCrSzhOWqPU=;
  b=OVDuODUEiBYIB3Qaf2JmDjXtYy/auOUEPQZj/GKKgbttw8yHtbX9P0Rs
   Z88iM9bFacSlWUBfN9Rwbr4Tf7xekSc9JWUVBReGiwl6kDc/FaeKyMN9y
   /29xeFtV8/hFGFLY12ElU3yB6dV44oJbwjfgU5Zcdzd3Js4rbtIPdJJCd
   ZNOQlW4K4kTSK6ZC0I6JD7/p7CZLykq06n9S8argInnTiL307EBxydTms
   lMoBxPPX2dtDxhVygJiwxGRjPcFXhpAgRD2o6JK6kAEplDVoF0UUnkCBw
   VQeuLvAQ6xR4aG24ZsKkCNm8jg4jnoNKnO4uEm7nsASh3ELRVQQAotvCc
   A==;
X-CSE-ConnectionGUID: VhrHaBaDR3S4G+qQmMqe4g==
X-CSE-MsgGUID: zqvCG7/CSYGnlBVcm1h0Ww==
Authentication-Results: smtp-out-03.simnet.is; dkim=none (message not signed) header.i=none
X-SBRS: 3.3
X-IPAS-Result: =?us-ascii?q?A2EJAAApbbpnhVjoacJaGwEBAgIBAQUBARQBAQMDAQFBg?=
 =?us-ascii?q?UAFAQEMAYJDfYFkiCWOIZFKjE0UgXIHAQEBDzETBAEBBIUDixIoNQgOAQIEA?=
 =?us-ascii?q?QEBAQMCAwEBAQEBAQEBAQEBCwEBBgEBAQEBAQYHAhABAQEBQA47hTVGDYUsL?=
 =?us-ascii?q?IErXy18gykBgmSuEoE0gQGDHNsYgV4QgUgBhWuCYwGFa4R3PAaCDYFHA4EGb?=
 =?us-ascii?q?UoHb4QGI0aGGASCGBeBQIICgWqBUByEZVSFIxwvRoFfhx4gkB9IgSEDWSwBV?=
 =?us-ascii?q?RMNCgsHBYFxAzUMCy4VMoEUQzc3gg5pSToCDQI1gh58giuCW4F5hEOERoVSg?=
 =?us-ascii?q?hGLOYMZHTYKAwsYDUgRLDcUG0RuB6AAPYM2CT8zAQEsBAxRAQc5Qy0TAzAGB?=
 =?us-ascii?q?AsYBQENPQYpkkEmMo9YgUSMT5NTgT6EJYZcgzGCC5VKMyKDYYFXkWoMOpJLm?=
 =?us-ascii?q?H2CWKEiGTcrhDuBaAGCFCwHGggwO4JnCUkZD44HIwMWiDXEa3g8AgcLAQEDC?=
 =?us-ascii?q?ZFaAQE?=
IronPort-PHdr: A9a23:QruekBOIYrPxpuP5mwkl6ncoWUAX0o4cXyYO74Y/zrVTbuH7pNL5P
 UnZ6OkrjUSaFYnY6vcRje3QvuigXGEb+p+OvTgEd4AETB4Kj8ga3kQgDceJBFe9LavsaCo3d
 Pk=
IronPort-Data: A9a23:X22AX6NWongdMj3vrR0hkMFynXyQoLVcMsEvi/8bNLSZYAhShG1co
 T9OB3fTeL2UNj+2P4gyK5O+xf41yceBzNNlGQpq/CoxFSoUpJrID4TFIhj9NHyYI5yfEklts
 MhEMIKeIstoECKG9xn3bem/8ics2K/YSOusBrWVZi4ZqWOIMMsEoUsLd7kR0tc00LBVej+wh
 O8eyiGn1DWN1ztvLmsI8OTT7h9usvqaVFgw5wBnNfxHtVWPxyJOUJsUdfrudSekGdQFRLThG
 76YkLrjoD6Br04kBo6rz7ukfBFbS+OObVSCgydYBvX+0kISqkTevkpD2N80MC+73B3Qx40ql
 r2hzKCNdDvFV0G0dI41XBReHjt3OetM5bDcSZTUmZfPkEfPIyDnzqVjAEw/Y9MRp+gpC2ser
 a1IJWEAMh7Z2OjpkLm1FbA12Z55c5S1ZI9C639tkmCHAKp+HcHNSP2iCbO0pNsVrpkm8aH2P
 ptDM1KDFSj9XiCjGmv7Kbpllbn5iyf1LmEB9AvL/fM5vDDawlR73bG3bNHfd9DST+xYzx2Sz
 o7k1z2iW0lFbrRz6tYkHlaE3LKncfbTAdpKfFGA3qc0xgXVnipLVUF+uWKT+ZGRklS5V89UN
 3sa8y8vqbla3EGwR7ERZTXhyJK/lkBaAoE4/9ESslnXl/KOuVzAXgDocxYYADAYnJ5nLdAV/
 gfhc+PBXVRHrLCTQHSBwbaYxRvaETQVN2ILeRgfRgID5dT5yKlr5v4YZo8+eEIdpoSd9QDYm
 1hmngBn71kgpZJjO5GAwLzyq2nESq4l4eICzl6/smqNtmuVbWM+DmCiwQCzAf1odO51QrQd1
 ZStdgf3AO0mVPmweCKxrOolIrGzx/+vORHm2mUzMNo4zjGI4nP/ctUFiN1+DB8B3scsZz7yf
 ArBuAZJ/phDLT7yN+lpYpmtTcUxpUTiPY20CraNNocIOMMrMl/XlM1tTRf4M2TFmkcEiqA6P
 5qHN8e3ZZofIf83l2ruHLhBuVMt7jIn20j8GtfQ9CWI1760WnWQELddD0TbO4jV64vf/FWEr
 IcDXyeQ8D1ETef7YzX/+5McNhYGIHI6DJawrNZYHsaHPA8jFGw/Bvv5xbI6Z5cjm6VTi/eO8
 nyjMnK003LhhGbbbBeLb2h5b6P+GM4l62w6JjBqPE3AN2UfjZiH0qcFV5IddJUdr9c/4r1td
 vwgYsjcDaEaItjYwAg1YZ74pY1kUR2kgwOSIiaoCATTmbY8FmQlHfe5JmPSGDkyM8ahiScpi
 5ybvj43rLIdRh9+SdTXbeq1yEOg+CBH3vxzRFeOI8I7lKTQHGpCdXWZYhwfepBkxfD/Kt2yj
 Vn+7fAw/rClnmPN2IOV7Z1oVq/weweEImJUHnPA8ZG9PjTA82yozOdoCbnUJWmDDjytpP76P
 I25Ks0Q1tVaxD6mVKIhSt5WIV4WvYS/z1On5l04RyuSMTxH9JsxfiPdtSWwikG97uQF6VrpC
 x7nFihyPLSNMYvlHjYsyPkNM4y+OQUvsmCKt5wdeRymjAcpp+DveRsJYHGxZNl1d+Ad3HUNm
 rx54JZ+Bs3WokZCD+tqeQgNqT7cdCBeDf953nzYaaey4jcWJph5ScS0IkfLDFunMr2g7mFCz
 ueouZf/
IronPort-HdrOrdr: A9a23:EE9Xmq1DuMJ+l31SOj/gigqjBLkkLtp133Aq2lEZdPWaSL37qy
 mLpoVj6faUskd2ZJhOo7G90cW7IU80lqQFhrX5X43SODUO0VHAROoJgOeMrQEIcBeOk9K1u5
 0QEJSWcOeAdWRHsQ==
X-Talos-CUID: =?us-ascii?q?9a23=3AMN7ZAmmrFrJUQtkjUeQExCD4FDvXOUPd1lfZCUa?=
 =?us-ascii?q?UMz1SFJLWUGaV3bppz8U7zg=3D=3D?=
X-Talos-MUID: =?us-ascii?q?9a23=3AFa+dsQ74OJPhT19DtIHbon82xox6+rqFJx9Kuq4?=
 =?us-ascii?q?3lM+AHxJ7Pm6d1AuoF9o=3D?=
X-IronPort-Anti-Spam-Filtered: true
X-IronPort-AV: E=Sophos;i="6.13,308,1732579200"; 
   d="8'?diff'?bugs'?scan'208";a="38380374"
Received: from vist-zimproxy-02.vist.is ([194.105.232.88])
  by smtp-out-03.simnet.is with ESMTP/TLS/ECDHE-RSA-AES256-GCM-SHA384; 23 Feb 2025 00:45:27 +0000
Received: from localhost (localhost [127.0.0.1])
	by vist-zimproxy-02.vist.is (Postfix) with ESMTP id 16F0644464B0;
	Sun, 23 Feb 2025 00:45:27 +0000 (GMT)
Received: from vist-zimproxy-02.vist.is ([127.0.0.1])
 by localhost (vist-zimproxy-02.vist.is [127.0.0.1]) (amavis, port 10032)
 with ESMTP id 4NU4blXiPVLn; Sun, 23 Feb 2025 00:45:25 +0000 (GMT)
Received: from localhost (localhost [127.0.0.1])
	by vist-zimproxy-02.vist.is (Postfix) with ESMTP id BCD4544464BA;
	Sun, 23 Feb 2025 00:45:25 +0000 (GMT)
Received: from vist-zimproxy-02.vist.is ([127.0.0.1])
 by localhost (vist-zimproxy-02.vist.is [127.0.0.1]) (amavis, port 10026)
 with ESMTP id o6ee-k1andZD; Sun, 23 Feb 2025 00:45:25 +0000 (GMT)
Received: from kassi.invalid.is (85-220-33-163.dsl.dynamic.simnet.is [85.220.33.163])
	by vist-zimproxy-02.vist.is (Postfix) with ESMTPS id 9319044464B0;
	Sun, 23 Feb 2025 00:45:25 +0000 (GMT)
Received: from bg by kassi.invalid.is with local (Exim 4.98)
	(envelope-from <bg@kassi.invalid.is>)
	id 1tm07Y-000000001Q9-2qOF;
	Sun, 23 Feb 2025 00:45:24 +0000
Date: Sun, 23 Feb 2025 00:45:24 +0000
From: Bjarni Ingi Gislason <bjarniig@simnet.is>
To: lvm-devel@lists.linux.dev
Cc: Debian Bug Tracking System <submit@bugs.debian.org>
Subject: dmstats.8: Some remarks and a patch with editorial changes for this
 man page
Message-ID: <174027127922.5406.10893049578142807374.reportbug@kassi.invalid.is>
Precedence: bulk
X-Mailing-List: lvm-devel@lists.linux.dev
List-Id: <lvm-devel.lists.linux.dev>
List-Subscribe: <mailto:lvm-devel+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:lvm-devel+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="QptRmfnMJrtLjQnL"
Content-Disposition: inline
X-Mailer: reportbug 13.1.0


--QptRmfnMJrtLjQnL
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

an.tmac:<stdin>:53: style: use of deprecated macro: .PD
an.tmac:<stdin>:252: style: use of deprecated macro: .PD

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

--QptRmfnMJrtLjQnL
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="chk_man.err.dmstats.8"

file is dmstats.8

Output from "mandoc -T lint  dmstats.8": (shortened list)

      1 input text line longer than 80 bytes: Name             RgI...
      3 input text line longer than 80 bytes: vg_hex\-lv_home     ...
      5 skipping paragraph macro: br after br

-.-.

Output from "test-groff -mandoc -t -ww -z dmstats.8": (shortened list)

     24 	Use macro '.B' for one argument or split argument.
      9 	Use macro '.I' for one argument or split argument.
     24 .BR is for at least 2 arguments, got 1
      9 .IR is for at least 2 arguments, got 1

-.-.

Lines containing '\c' (' \c' does not make sense):

503:.B \-\-units \c

-.-

Change '-' (\-) to '\(en' (en-dash) for a (numeric) range.
GNU gnulib has recently (2023-06-18) updated its
"build_aux/update-copyright" to recognize "\(en" in man pages.

dmstats.8:470:expressed as a hyphen separated range, for example: '1\-10'.

-.-.

Add a (no-break, "\ " or "\~") space between a number and a unit,
as these are not one entity.

1114:Create a 32M region 1G into device d0

-.-.

Add a "\&" after "e.g." and "i.e.", or use English words
(man-pages(7)).
Abbreviation points should be protected against being interpreted as
an end of sentence, if they are not, and that independent of the
current place on the line.

511:Can also specify custom units e.g. \fB\-\-units\ 3M\fP.

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

[List of affected lines removed]

-.-.

The name of a man page is typeset in bold and the section in roman
(see man-pages(7)).

798:extents). This currently includes \fBxfs(5)\fP and \fBext4(5)\fP.
801:group, and the group alias is set to the \fBbasename(3)\fP of the

-.-.

Use thousand markers to make large numbers easy to read

560:is equivalent to 10000000. Latency values with a precision of less than

-.-.

Remove quotes when there is a printable
but no space character between them
and the quotes are not for emphasis (markup),
for example as an argument to a macro.

1:.TH DMSTATS 8 "Jun 23 2016" "Linux" "MAINTENANCE COMMANDS"

-.-.

Output from "test-groff  -mandoc -t -K utf8 -rF0 -rHY=0 -rCHECKSTYLE=10 -ww -z ":

an.tmac:<stdin>:53: style: use of deprecated macro: .PD
an.tmac:<stdin>:71: misuse, warning: .IR is for at least 2 arguments, got 1
	Use macro '.I' for one argument or split argument.
an.tmac:<stdin>:71: misuse, warning: .BR is for at least 2 arguments, got 1
	Use macro '.B' for one argument or split argument.
an.tmac:<stdin>:71: misuse, warning: .IR is for at least 2 arguments, got 1
	Use macro '.I' for one argument or split argument.
an.tmac:<stdin>:71: misuse, warning: .BR is for at least 2 arguments, got 1
	Use macro '.B' for one argument or split argument.
an.tmac:<stdin>:71: misuse, warning: .IR is for at least 2 arguments, got 1
	Use macro '.I' for one argument or split argument.
an.tmac:<stdin>:85: misuse, warning: .BR is for at least 2 arguments, got 1
	Use macro '.B' for one argument or split argument.
an.tmac:<stdin>:85: misuse, warning: .IR is for at least 2 arguments, got 1
	Use macro '.I' for one argument or split argument.
an.tmac:<stdin>:117: misuse, warning: .BR is for at least 2 arguments, got 1
	Use macro '.B' for one argument or split argument.
an.tmac:<stdin>:117: misuse, warning: .IR is for at least 2 arguments, got 1
	Use macro '.I' for one argument or split argument.
an.tmac:<stdin>:117: misuse, warning: .BR is for at least 2 arguments, got 1
	Use macro '.B' for one argument or split argument.
an.tmac:<stdin>:131: misuse, warning: .BR is for at least 2 arguments, got 1
	Use macro '.B' for one argument or split argument.
an.tmac:<stdin>:147: misuse, warning: .BR is for at least 2 arguments, got 1
	Use macro '.B' for one argument or split argument.
an.tmac:<stdin>:156: misuse, warning: .BR is for at least 2 arguments, got 1
	Use macro '.B' for one argument or split argument.
an.tmac:<stdin>:176: misuse, warning: .BR is for at least 2 arguments, got 1
	Use macro '.B' for one argument or split argument.
an.tmac:<stdin>:191: misuse, warning: .BR is for at least 2 arguments, got 1
	Use macro '.B' for one argument or split argument.
an.tmac:<stdin>:221: misuse, warning: .BR is for at least 2 arguments, got 1
	Use macro '.B' for one argument or split argument.
an.tmac:<stdin>:234: misuse, warning: .BR is for at least 2 arguments, got 1
	Use macro '.B' for one argument or split argument.
an.tmac:<stdin>:250: misuse, warning: .BR is for at least 2 arguments, got 1
	Use macro '.B' for one argument or split argument.
an.tmac:<stdin>:250: misuse, warning: .IR is for at least 2 arguments, got 1
	Use macro '.I' for one argument or split argument.
an.tmac:<stdin>:252: style: use of deprecated macro: .PD
an.tmac:<stdin>:531: misuse, warning: .BR is for at least 2 arguments, got 1
	Use macro '.B' for one argument or split argument.
an.tmac:<stdin>:531: misuse, warning: .IR is for at least 2 arguments, got 1
	Use macro '.I' for one argument or split argument.
an.tmac:<stdin>:537: misuse, warning: .BR is for at least 2 arguments, got 1
	Use macro '.B' for one argument or split argument.
an.tmac:<stdin>:537: misuse, warning: .IR is for at least 2 arguments, got 1
	Use macro '.I' for one argument or split argument.
an.tmac:<stdin>:537: misuse, warning: .BR is for at least 2 arguments, got 1
	Use macro '.B' for one argument or split argument.
an.tmac:<stdin>:602: misuse, warning: .BR is for at least 2 arguments, got 1
	Use macro '.B' for one argument or split argument.
an.tmac:<stdin>:622: misuse, warning: .BR is for at least 2 arguments, got 1
	Use macro '.B' for one argument or split argument.
an.tmac:<stdin>:645: misuse, warning: .BR is for at least 2 arguments, got 1
	Use macro '.B' for one argument or split argument.
an.tmac:<stdin>:651: misuse, warning: .BR is for at least 2 arguments, got 1
	Use macro '.B' for one argument or split argument.
an.tmac:<stdin>:672: misuse, warning: .BR is for at least 2 arguments, got 1
	Use macro '.B' for one argument or split argument.
an.tmac:<stdin>:678: misuse, warning: .BR is for at least 2 arguments, got 1
	Use macro '.B' for one argument or split argument.
an.tmac:<stdin>:699: misuse, warning: .BR is for at least 2 arguments, got 1
	Use macro '.B' for one argument or split argument.
an.tmac:<stdin>:707: misuse, warning: .BR is for at least 2 arguments, got 1
	Use macro '.B' for one argument or split argument.
an.tmac:<stdin>:707: misuse, warning: .IR is for at least 2 arguments, got 1
	Use macro '.I' for one argument or split argument.

-.-.

Additionally:

  Fix some arguments for '.TP'.  A single-font macro does not work with
'\c', so use a two-font macro.

-.-

  Use the pair ".na / .ad" to set no-adjustment (same result as '.ad l')
and '.ad' to restore previous adjustment.
[Replacing ".ad l" ... ".ad b"]

  Set singular '.ad b' to '.ad \*(AD' as the user should have the choice to
control the adjustment from the command line.

  Add an empty string to string 'AD' with '.as AD "\"' to avoid a warning
about an undefined string.

-.-

Generally:

Split (sometimes) lines after a punctuation mark; before a conjunction.

--QptRmfnMJrtLjQnL
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="dmstats.8.diff"

--- dmstats.8	2025-02-22 21:03:55.192613432 +0000
+++ dmstats.8.new	2025-02-23 00:39:44.791657060 +0000
@@ -1,4 +1,4 @@
-.TH DMSTATS 8 "Jun 23 2016" "Linux" "MAINTENANCE COMMANDS"
+.TH DMSTATS 8 "Jun 23 2016" Linux "MAINTENANCE COMMANDS"
 .
 .de OPT_PROGRAMS
 .  RB [ \-\-allprograms | \-\-programid
@@ -38,6 +38,7 @@
 .  nop Capitalise to use multiples of 1000 (S.I.) instead of 1024.
 ..
 .
+.as AD "\" define the string if not defined on the command line
 .SH NAME
 .
 dmstats \(em device-mapper statistics management
@@ -54,42 +55,42 @@ dmstats \(em device-mapper statistics ma
 .HP
 .B dmstats
 .de CMD_COMMAND
-.  ad l
+.  na
 .  nh
-.  IR command
+.  I command
 .  IR device_name \ |
-.  BR \-\-major
-.  IR major
-.  BR \-\-minor
+.  B \-\-major
+.  I major
+.  B \-\-minor
 .  IR minor \ |
 .  BR \-u | \-\-uuid
-.  IR uuid
+.  I uuid
 .  RB [ \-v | \-\-verbose ]
 .  hy
-.  ad b
+.  ad
 ..
 .CMD_COMMAND
 .
 .HP
 .B dmstats
 .de CMD_CLEAR
-.  ad l
+.  na
 .  nh
-.  BR clear
-.  IR device_name
+.  B clear
+.  I device_name
 .  OPT_PROGRAMS
 .  OPT_REGIONS
 .  hy
-.  ad b
+.  ad
 ..
 .CMD_CLEAR
 .
 .HP
 .B dmstats
 .de CMD_CREATE
-.  ad l
+.  na
 .  nh
-.  BR create
+.  B create
 .  IR device_name ...| file_path ...| \fB\-\-alldevices
 .  RB [ \-\-areas
 .  IR nr_areas | \fB\-\-areasize
@@ -104,63 +105,63 @@ dmstats \(em device-mapper statistics ma
 .  RB [ \-\-nogroup ]
 .  RB [ \-\-precise ]
 .  RB [ \-\-start
-.  IR start_sector
-.  BR \-\-length
+.  I start_sector
+.  B \-\-length
 .  IR length | \fB\-\-segments ]
 .  RB [ \-\-userdata
 .  IR user_data ]
 .  RB [ \-\-programid
 .  IR id ]
 .  hy
-.  ad b
+.  ad
 ..
 .CMD_CREATE
 .
 .HP
 .B dmstats
 .de CMD_DELETE
-.  ad l
+.  na
 .  nh
-.  BR delete
+.  B delete
 .  IR device_name | \fB\-\-alldevices
 .  OPT_PROGRAMS
 .  OPT_REGIONS
 .  hy
-.  ad b
+.  ad
 ..
 .CMD_DELETE
 .
 .HP
 .B dmstats
 .de CMD_GROUP
-.  ad l
+.  na
 .  nh
-.  BR group
+.  B group
 .  RI [ device_name | \fB\-\-alldevices ]
 .  RB [ \-\-alias
 .  IR name ]
 .  RB [ \-\-regions
 .  IR regions ]
 .  hy
-.  ad b
+.  ad
 ..
 .CMD_GROUP
 .HP
 .B dmstats
 .de CMD_HELP
-.  ad l
-.  BR help
+.  na
+.  B help
 .  RB [ \-c | \-C | \-\-columns ]
-.  ad b
+.  ad
 ..
 .CMD_HELP
 .
 .HP
 .B dmstats
 .de CMD_LIST
-.  ad l
+.  na
 .  nh
-.  BR list
+.  B list
 .  RI [ device_name ]
 .  RB [ \-\-histogram ]
 .  OPT_PROGRAMS
@@ -171,31 +172,31 @@ dmstats \(em device-mapper statistics ma
 .  RB [ \-\-notimesuffix ]
 .  RB [ \-v | \-\-verbose ]
 .  hy
-.  ad b
+.  ad
 ..
 .CMD_LIST
 .
 .HP
 .B dmstats
 .de CMD_PRINT
-.  ad l
+.  na
 .  nh
-.  BR print
+.  B print
 .  RI [ device_name ]
 .  RB [ \-\-clear ]
 .  OPT_PROGRAMS
 .  OPT_REGIONS
 .  hy
-.  ad b
+.  ad
 ..
 .CMD_PRINT
 .
 .HP
 .B dmstats
 .de CMD_REPORT
-.  ad l
+.  na
 .  nh
-.  BR report
+.  B report
 .  RI [ device_name ]
 .  RB [ \-\-interval
 .  IR seconds ]
@@ -216,41 +217,41 @@ dmstats \(em device-mapper statistics ma
 .  RB [ \-\-nosuffix ]
 .  RB [ \-\-notimesuffix ]
 .  hy
-.  ad b
+.  ad
 ..
 .CMD_REPORT
 .HP
 .B dmstats
 .de CMD_UNGROUP
-.  ad l
+.  na
 .  nh
-.  BR ungroup
+.  B ungroup
 .  RI [ device_name | \fB\-\-alldevices ]
 .  RB [ \-\-groupid
 .  IR id ]
 .  hy
-.  ad b
+.  ad
 ..
 .CMD_UNGROUP
 .HP
 .B dmstats
 .de CMD_UPDATE_FILEMAP
-.  ad l
+.  na
 .  nh
-.  BR update_filemap
-.  IR file_path
+.  B update_filemap
+.  I file_path
 .  RB [ \-\-groupid
 .  IR id ]
 .  RB [ \-\-follow
 .  IR follow_mode ]
 .  OPT_FOREGROUND
 .  hy
-.  ad b
+.  ad
 ..
 .CMD_UPDATE_FILEMAP
 .
 .PD
-.ad b
+.ad \*(AD
 .
 .SH DESCRIPTION
 .
@@ -300,8 +301,9 @@ results.
 Specify the number of statistics areas to create within a new region.
 .
 .TP
-.B \-\-areasize \fIarea_size\fR[\c
+.BI \-\-areasize " area_size\fR[\c"
 .UNITS
+.br
 Specify the size of areas into which a new region should be divided. An
 optional suffix selects units of:
 .HELP_UNITS
@@ -382,7 +384,7 @@ The daemon will not fork into the backgr
 Specify the group to operate on.
 .
 .TP
-.B \-\-bounds \fIhistogram_boundaries\c
+.BI \-\-bounds " histogram_boundaries\c"
 .RB [ ns | us | ms | s ]
 Specify the boundaries of a latency histogram to be tracked for the
 region as a comma separated list of latency values. Latency values are
@@ -404,7 +406,7 @@ repeating reports. If \fB\-\-interval\fP
 reports will continue to repeat until interrupted.
 .
 .TP
-.B \-\-length \fIlength\fR[\c
+.BI \-\-length " length\fR[\c"
 .UNITS
 Specify the length of a new statistics region in sectors. An optional
 suffix selects units of:
@@ -467,7 +469,7 @@ Specify the region to operate on.
 .B \-\-regions \fIregion_list
 Specify a list of regions to group. The group list is a comma-separated
 list of region identifiers. Continuous sequences of identifiers may be
-expressed as a hyphen separated range, for example: '1\-10'.
+expressed as a hyphen separated range, for example: '1\(en10'.
 .
 .TP
 .B \-\-relative
@@ -483,7 +485,7 @@ specifying column names and their valid
 supported comparison operators.
 .
 .TP
-.B \-\-start \fIstart\fR[\c
+.BI \-\-start " start\fR[\c"
 .UNITS
 Specify the start offset of a new statistics region in sectors. An
 optional suffix selects units of:
@@ -500,15 +502,16 @@ the \fB\-\-nogroup\fP option is given. W
 alias may be specified using the \fB\-\-alias\fP option.
 .
 .TP
-.B \-\-units \c
+.BR \-\-units " \c"
 .RI [ units ] \c
 .RB [ h | H | \c
 .UNITS
+.br
 Set the display units for report output.
 All sizes are output in these units:
 .RB ( h )uman-readable,
 .HELP_UNITS
-Can also specify custom units e.g. \fB\-\-units\ 3M\fP.
+Can also specify custom units e.g.\& \fB\-\-units\ 3M\fP.
 .
 .TP
 .B \-\-userdata \fIuser_data
@@ -556,8 +559,9 @@ configured interval duration) on the fin
 .sp
 Latencies are given in nanoseconds. An optional unit suffix of ns, us,
 ms, or s may be given after each value to specify units of nanoseconds,
-microseconds, milliseconds or seconds respectively, so for example, 10ms
-is equivalent to 10000000. Latency values with a precision of less than
+microseconds, milliseconds or seconds respectively, so for example,
+10\~ms is equivalent to 10,000,000.
+Latency values with a precision of less than
 one millisecond can only be used when precise timestamps are enabled: if
 \fB\-\-precise\fP is not given and values less than one millisecond are
 used it will be enabled automatically.
@@ -795,7 +799,7 @@ of interest.
 To be able to use file mapping, the file must be backed by a
 device-mapper device, and in a file system that supports the FIEMAP
 ioctl (and which returns data describing the physical location of
-extents). This currently includes \fBxfs(5)\fP and \fBext4(5)\fP.
+extents). This currently includes \fBxfs\fP(5) and \fBext4\fP(5).
 .P
 By default the regions making up a file are placed together in a
 group, and the group alias is set to the \fBbasename(3)\fP of the
@@ -1111,7 +1115,7 @@ Create a whole-device region with one ar
 .br
 vg00/lvol1: Created new region with 1 area(s) as region ID 0
 .P
-Create a 32M region 1G into device d0
+Create a 32\~MB region 1\~GB into device d0
 .br
 #
 .B dmstats create \-\-start 1G \-\-length 32M d0
@@ -1120,7 +1124,6 @@ d0: Created new region with 1 area(s) as
 .P
 Create a whole-device region with 8 areas on every device
 .br
-.br
 #
 .B dmstats create \-\-areas 8
 .br
@@ -1138,20 +1141,18 @@ vg00\-lvol2: Created new region with 8 a
 .P
 Delete all regions on all devices
 .br
-.br
 #
 .B dmstats delete \-\-alldevices \-\-allregions
 .P
-Create a whole-device region with areas 10\ GiB in size on vg00/lvol1
+Create a whole-device region with areas 10\ GB in size on vg00/lvol1
 using dmsetup
 .br
-.br
 #
 .B dmsetup stats create \-\-areasize 10G vg00/lvol1
 .br
 vg00\-lvol1: Created new region with 5 area(s) as region ID 1
 .P
-Create a 1\ GiB region with 16 areas at the start of vg00/lvol1
+Create a 1\ GB region with 16 areas at the start of vg00/lvol1
 .br
 #
 .B dmstats create \-\-start 0 \-\-len 1G \-\-areas=16 vg00/lvol1
@@ -1163,34 +1164,55 @@ List the statistics regions registered o
 #
 .B dmstats list vg00/lvol1
 .br
-Name             RgID  RStart RSize  #Areas ASize  ProgID
-.br
-vg00\-lvol1           0      0 61.00g      1 61.00g dmstats
-.br
-vg00\-lvol1           1 61.00g 19.20g      1 19.20g dmstats
-.br
-vg00\-lvol1           2 80.20g  2.14g      1  2.14g dmstats
+.TS
+l l l l l l l
+l n n n n n l .
+Name	RgID	RStart	RSize	#Areas	ASize	ProgID
+vg00\-lvol1	0	0	61.00g	1	61.00g	dmstats
+vg00\-lvol1	1	61.00g	19.20g	1	19.20g	dmstats
+vg00\-lvol1	2	80.20g	2.14g	1	2.14g	dmstats
+.TE
 .P
 Display five statistics reports for vg00/lvol1 at an interval of one second
 .br
-.br
 #
 .B dmstats report \-\-interval 1 \-\-count 5 vg00/lvol1
 .br
 #
 .B dmstats report
 .br
-Name             RgID  ArID  AStart ASize  RRqM/s   WRqM/s   R/s   W/s    RSz/s WSz/s   AvRqSz  QSize Util%      AWait RdAWa WrAWa
-.br
-vg_hex\-lv_home       0     0      0 61.00g     0.00     0.00  0.00 218.00     0   1.04m   4.50k  2.97      81.70 13.62  0.00 13.62
-.br
-vg_hex\-lv_home       1     0 61.00g 19.20g     0.00     0.00  0.00   5.00     0 548.00k 109.50k  0.14      11.00 27.40  0.00 27.40
-.br
-vg_hex\-lv_home       2     0 80.20g  2.14g     0.00     0.00  0.00  14.00     0   1.15m  84.00k  0.39      18.70 27.71  0.00 27.71
+.nr ol \n(.l
+.nr oL \n(LL
+.ie n \{\
+.  ll 125m
+.  nr LL 125m
+.\}
+.el \{\
+.  ll 120m
+.  nr LL 120m
+.  nr oi \n(.i
+.  nr oo \n(.o
+.  in 0
+.  po 0
+.\}
+.TS
+l1 l1 l1 l1 l1 l1 l1 l1 l1 l1 l1 l1 l1 l1 l1 l1 l
+l1 n1 n1 n1 n1 n1 n1 n1 n1 n1 n1 n1 n1 n1 n1 n1 n.
+Name	RgID	ArID	AStart	ASize	RRqM/s	WRqM/s	R/s	W/s	RSz/s	WSz/s	AvRqSz	QSize	Util%	AWait	RdAWa	WrAWa
+vg_hex\-lv_home	0	0	0	61.00g	0.00	0.00	0.00	218.00	0	1.04m	4.50k	2.97	81.70	13.62	0.00	13.62
+vg_hex\-lv_home	1	0	61.00g	19.20g	0.00	0.00	0.00	5.00	0	548.00k	109.50k	0.14	11.00	27.40	0.00	27.40
+vg_hex\-lv_home	2	0	80.20g	2.14g	0.00	0.00	0.00	14.00	0	1.15m	84.00k	0.39	18.70	27.71	0.00	27.71
+.TE
+.br
+.ll \n(olu
+.nr LL \n(oLu
+.if t \{\
+.po \n(oou
+.in \n(oiu
+.\}
 .P
 Create one region for reach target contained in device vg00/lvol1
 .br
-.br
 #
 .B dmstats create \-\-segments vg00/lvol1
 .br
@@ -1201,7 +1223,7 @@ vg00\-lvol1: Created new region with 1 a
 vg00\-lvol1: Created new region with 1 area(s) as region ID 2
 .P
 Create regions mapping each file in the directory images/ and place
-them into separate groups, each named after the corresponding file
+them into separate groups, each named after the corresponding file.
 .br
 #
 .B dmstats create \-\-filemap images/*

--QptRmfnMJrtLjQnL
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

--QptRmfnMJrtLjQnL--
