From: Petr Rockai <prockai@redhat.com>
Date: Wed, 10 Sep 2008 14:43:26 +0200
Subject: [PATCH] (4/6) new vgreduce --removemissing semantics
In-Reply-To: <87r67s6x1m.fsf@eriador.mornfall.net> (Petr Rockai's message of
	"Wed, 10 Sep 2008 13:49:09 +0200")
References: <87y73k24i3.fsf@eriador.mornfall.net>
	<87r67s6x1m.fsf@eriador.mornfall.net>
Message-ID: <87ljy06uj5.fsf@eriador.mornfall.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

Petr Rockai <prockai@redhat.com> writes:
> but please bear with me, I will come with a better one in a few minutes.
I am attaching a new version of the patch that solves the issue in a hopefully
better way, and also adds a comment on what is the problem with the original
approach.

Yours,
   Petr.

-------------- next part --------------
A non-text attachment was scrubbed...
Name: vgreduce-fix.diff
Type: text/x-diff
Size: 2302 bytes
Desc: vgreduce-fix.diff
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20080910/4118a54d/attachment.bin>
-------------- next part --------------

-- 
Peter Rockai | me()mornfall!net | prockai()redhat!com
 http://blog.mornfall.net | http://web.mornfall.net

"In My Egotistical Opinion, most people's C programs should be
 indented six feet downward and covered with dirt."
     -- Blair P. Houghton on the subject of C program indentation
