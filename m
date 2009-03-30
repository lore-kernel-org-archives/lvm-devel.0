From: Petr Rockai <prockai@redhat.com>
Date: Mon, 30 Mar 2009 17:14:32 +0200
Subject: [PATCH] lvconvert --repair
In-Reply-To: <49CA4006.2010804@redhat.com> (Milan Broz's message of "Wed, 25
	Mar 2009 15:30:30 +0100")
References: <87skn1p0jo.fsf@eriador.mornfall.net>
	<498B2A94.7050105@redhat.com> <877i3y9od8.fsf@eriador.mornfall.net>
	<87skmkc7q5.fsf@eriador.mornfall.net> <49CA4006.2010804@redhat.com>
Message-ID: <8763hrf3fr.fsf@eriador.mornfall.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Milan Broz <mbroz@redhat.com> writes:
> please try this test - it tries to allocate new log - not sure if it is what we want,
> but lvconvert fails but log lv is later visible, vg is still inconsistent
> and I am confused what the correct state should be:-)
The problem was that the code neglected to write out the consistent volume
before trying to add new bits (which could obviously fail). The attached
version of the patch fixes that (it also contains your test now).

-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvconvert-repair.diff
Type: text/x-diff
Size: 19931 bytes
Desc: lvconvert-repair.diff
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20090330/04afeba8/attachment.bin>
-------------- next part --------------

Yours,
   Petr.

-- 
Peter Rockai | me()mornfall!net | prockai()redhat!com
 http://blog.mornfall.net | http://web.mornfall.net

"In My Egotistical Opinion, most people's C programs should be
 indented six feet downward and covered with dirt."
     -- Blair P. Houghton on the subject of C program indentation
