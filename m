From: Peter Rajnoha <prajnoha@redhat.com>
Date: Mon, 20 Apr 2009 11:57:50 +0200
Subject: [PATCH] Udev integration: udev rules 1/3
In-Reply-To: <20090415180703.GJ7843@agk.fab.redhat.com>
References: <49DC99BA.8000205@redhat.com>
	<20090415180703.GJ7843@agk.fab.redhat.com>
Message-ID: <49EC471E.9050703@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 04/15/2009 08:07 PM, Alasdair G Kergon wrote:
> On Wed, Apr 08, 2009 at 02:34:02PM +0200, Peter Rajnoha wrote:
>> # You can define your own permissions for DM devices here.
>> # ENV{DM_NAME}=="my_device", OWNER="peter", GROUP="peter", MODE="0644"
>  
> Can that be read from a separate file to avoid the need for manual editing
> when updating?  (Otherwise add markers so that a postinstall script
> can automatically update the file.)

Well, once there was this option "udev_permissions" (in /etc/udev/udev.conf)
which specified the directory in which the rules with permissions were
defined only. But it seems this was in past versions of udev and it's not
used anymore (it's not event documented now), so everybody defines the
permissions 'in situ'.

However, we can separate these permissions into a separate file -- it
should not matter if the permission is defined after or before the node
is created (the last permission defined is the one that matters). So we
can probably add a new file with permissions only, *but* then we have to
disable the "OPTIONS+="last_rule", which means that we have less control
over the rules because some other rule can add its own things to our
devices -- I tried this and I defined my permissions and some other
(external) rule changed the GROUP permission to "disk" (I did not
look for the rule which caused this exactly, but it happens...).
So it's safer this way. We have more control.

I've also considered the "IMPORT{FILE}" rule, which can import the contents
of the file, but this is bound to simple "KEY=VALUE" items. It seems we can't
use comparisons here (just like ENV{DM_NAME}=="my_device"). So this is not
the way we want either.

I would probably leave the OPTIONS+="last_rule" in our rules and define
permisssions here. Maybe add some marks, so it can be parsed and filled
in by scripts (as you have suggested) to add new permissions/subsystems.

>> # We won't send notifications for known subsystems since
>> # these have their own dedicated rules and the notification
>> # will be done after they finish their own actions.
>> ENV{DM_UUID}=="LVM-?*", GOTO="dm_end"
>  
> Again, how are these prefixes defined?
> - Each package will want to install it's own prefix handler.
>   Can that be done without having to edit files?

...the same here.

>> ENV{COOKIE}=="[0-9]*", RUN+="/sbin/dmsetup notify $env{COOKIE}", OPTIONS+="last_rule"
>  
> Since this is external input being passed to a trusted program, what is validating it?
> - Does that regex have implicit ^ and $ anchors around it?  (If not, add them.)
> - What if the variable is defined but empty?  (Change * to +) ?

Oh. Thanks, sure, we should not call notify when it's empty (it's not a big
problem, dmsetup will just properly fail when the input is not given). The thing
with these regexes is that they are not full regexes -- just "*", "?", "[ ]", "-" (range)
and "!" (not) (I haven't seen any other to be used in udev rules, also these ones are
documented only). So what can we do... hmm, maybe:

ENV{COOKIE}=="?*"
(we won't check if it's proper numeric value, dmsetup does that, so we can rely on it)

or

ENV{COOKIE}=="[0-9][0-9]*"
(well, I don't know... a little bit clumsy)

Anyway, if the input for dmsetup is wrong, dmsetup will just fail properly, so this is
not a big deal. The cookie value from kernel should be right.

(these are just my findings, so if I'm wrong with something, correct me, please)

Peter


