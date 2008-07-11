From: Petr Rockai <prockai@redhat.com>
Date: Fri, 11 Jul 2008 15:43:01 +0200
Subject: [PATCH] (3/3) new vgreduce --removemissing semantics
Message-ID: <87wsjs1qqi.fsf@eriador.mornfall.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

after a discussion with Alasdair, we have concluded that instead of using
"--consolidate" (which is not quite clear) for the new, safer semantics, we
will hijack existing --removemissing switch. To get the old (LV-removing)
behaviour, --force needs to be specified as well: the current --removemissing
handler will advise users about that (together with list of LVs that will need
to be removed or downconverted).

Note this breaks dmeventd as it is, but we likely want to use lvconvert
--repair there nevertheless and not vgreduce.

-------------- next part --------------
A non-text attachment was scrubbed...
Name: vgreduce-removemissing.diff
Type: text/x-diff
Size: 9795 bytes
Desc: vgreduce-removemissing.diff
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20080711/9af11bc9/attachment.bin>
-------------- next part --------------

Yours,
   Petr.

PS: About the remaining 2 patches in the set: partial activation did not change
yet (it'll come in separately with a name generation fix). The lvconvert
--repair patch essentially did not change.

-- 
Peter Rockai | me()mornfall!net | prockai()redhat!com
 http://blog.mornfall.net | http://web.mornfall.net

"In My Egotistical Opinion, most people's C programs should be
 indented six feet downward and covered with dirt."
     -- Blair P. Houghton on the subject of C program indentation
