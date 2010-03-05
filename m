From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Fri, 05 Mar 2010 10:57:32 +0100
Subject: PATCH: Replace mlockall() with interal implementation
In-Reply-To: <4B87F062.8090407@redhat.com>
References: <4B87D947.4060300@redhat.com> <4B87F062.8090407@redhat.com>
Message-ID: <4B90D58C.7090501@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

3rd version of mlockall() replace.

Fixing some comments:

- new text for lvm.conf
- using '1' for success for _maps_line
- checking sscanf ret value
- moved default string values to const char array in front of the source code.
- added simple statistic for size of locked areas and issue internal error
  if the size is different for mlock/munlock
- add some more libs to list of unlocked maps - (though some checks are still
  needed here.
- slightly changed debug output.

Zdenek
-------------- next part --------------
A non-text attachment was scrubbed...
Name: mlock_v3.patch
Type: text/x-patch
Size: 14154 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20100305/8ea75fff/attachment.bin>
