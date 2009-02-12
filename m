From: Petr Rockai <prockai@redhat.com>
Date: Thu, 12 Feb 2009 10:41:54 +0100
Subject: [PATCH] lvconvert --repair
In-Reply-To: <877i3y9od8.fsf@eriador.mornfall.net> (Petr Rockai's message of
	"Tue, 10 Feb 2009 18:46:11 +0100")
References: <87skn1p0jo.fsf@eriador.mornfall.net>
	<498B2A94.7050105@redhat.com> <877i3y9od8.fsf@eriador.mornfall.net>
Message-ID: <87skmkc7q5.fsf@eriador.mornfall.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Petr Rockai <prockai@redhat.com> writes:
>> - missing man page update
> indeed
The manpage update is still missing, but all the rest should be addressed in
the attached patch. (I will chop it up for commit, just sending in all the bits
together). I'll trow the manpage together later (this should not interfere with
review or acceptance, I hope).

Yours,
   Petr.

-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvconvert-repair.diff
Type: text/x-diff
Size: 19249 bytes
Desc: lvconvert-repair.diff
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20090212/683e0cba/attachment.bin>
-------------- next part --------------

-- 
Peter Rockai | me()mornfall!net | prockai()redhat!com
 http://blog.mornfall.net | http://web.mornfall.net

"In My Egotistical Opinion, most people's C programs should be
 indented six feet downward and covered with dirt."
     -- Blair P. Houghton on the subject of C program indentation
