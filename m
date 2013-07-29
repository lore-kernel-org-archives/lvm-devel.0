From: Peter Rajnoha <prajnoha@redhat.com>
Date: Mon, 29 Jul 2013 09:44:36 +0200
Subject: Now I'm convinced about Linux
In-Reply-To: <999744.9869.bm@smtp104.mail.ir2.yahoo.com>
References: <999744.9869.bm@smtp104.mail.ir2.yahoo.com>
Message-ID: <51F61D64.6070600@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 07/26/2013 06:37 PM, Kevin Chadwick wrote:
> Having a simple problem today that last_rule would solve just fine and
> finding that I must edit extra files or manage a packages file is

You should not be pushed into editing udev rules unless you do something
(very) extra. If something does not work correctly as expected, you
should submit a bug report against the relevant distro/package.

What exactly is the nature of the problem that needs such a manual
intervention? Also, what udev rules are we talking about exactly?

> quite convincing that they are right, especially the reason
> "Inconsistent behaviour" when that is exactly what I expect to be able
> to do on Unix and is so often made difficult just on Linux these days
> and it seems especially in code mainly managed by RedHat, though I do
> not a member of RedHat raising concerns about it.
> 
> I have tried creating /lib/udev/rules.d/zzz-arsewipingidiotfix.rules
> with LABEL="very_end"
> 
> but adding GOTO="very_end" to earlier udev rules
> (/etc/udev/rules.d/46-) is having no effect even after a udev restart?
> 
> Any ideas?
> 

Please, provide more information about the problem and if the problem
is related to LVM, then provide the LVM version as well please
Also, is this Fedora or RHEL or are you trying to use upstream
version directly?

Peter


