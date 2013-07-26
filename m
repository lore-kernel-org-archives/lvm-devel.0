From: Kevin Chadwick <ma1l1ists@yahoo.co.uk>
Date: Fri, 26 Jul 2013 17:37:44 +0100
Subject: Now I'm convinced about Linux
Message-ID: <999744.9869.bm@smtp104.mail.ir2.yahoo.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

I have often heard in certain circles that Linux messes things up by
trying to wipe peoples arses.

Having a simple problem today that last_rule would solve just fine and
finding that I must edit extra files or manage a packages file is
quite convincing that they are right, especially the reason
"Inconsistent behaviour" when that is exactly what I expect to be able
to do on Unix and is so often made difficult just on Linux these days
and it seems especially in code mainly managed by RedHat, though I do
not a member of RedHat raising concerns about it.

I have tried creating /lib/udev/rules.d/zzz-arsewipingidiotfix.rules
with LABEL="very_end"

but adding GOTO="very_end" to earlier udev rules
(/etc/udev/rules.d/46-) is having no effect even after a udev restart?

Any ideas?

-- 
_______________________________________________________________________

'Write programs that do one thing and do it well. Write programs to work
together. Write programs to handle text streams, because that is a
universal interface'

(Doug McIlroy)
_______________________________________________________________________


