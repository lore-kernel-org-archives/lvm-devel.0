From: Petr Rockai <prockai@redhat.com>
Date: Wed, 09 Jul 2008 17:13:27 +0200
Subject: [PATCH] "lenient" (backward-compatible) flag field
Message-ID: <87lk0bhyzs.fsf@eriador.mornfall.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi.

For description see below. The patch stood fairly well in my limited testing. I
have quickly ported the partial VG patches to use "flags" instead of "status"
for its new flags (MISSING_PV, specifically) and everything seemed to work
fine. I have also verified that metadata looks all right.

This should also facilitate a relatively easy fix for #454349, without
compromising backward compatibility.

Please review, thanks.

-------------- next part --------------
A non-text attachment was scrubbed...
Name: lenient-flags.diff
Type: text/x-diff
Size: 7980 bytes
Desc: lenient-flags.diff
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20080709/22151aef/attachment.bin>
-------------- next part --------------

Yours,
   Peter.

-- 
Peter Rockai | me()mornfall!net | prockai()redhat!com
 http://blog.mornfall.net | http://web.mornfall.net

"In My Egotistical Opinion, most people's C programs should be
 indented six feet downward and covered with dirt."
     -- Blair P. Houghton on the subject of C program indentation
