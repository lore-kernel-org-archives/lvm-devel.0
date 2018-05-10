From: Bryn M. Reeves <bmr@redhat.com>
Date: Thu, 10 May 2018 15:09:49 +0100
Subject: boom packaging question
In-Reply-To: <068965e5-0e34-0d7f-a1a5-d55db0200895@redhat.com>
References: <068965e5-0e34-0d7f-a1a5-d55db0200895@redhat.com>
Message-ID: <20180510140948.GA4313@wlan-5-199.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Thu, May 10, 2018 at 02:07:23PM +0200, Marian Csontos wrote:
> Bryn, I do wonder, shall we treat files in /boot/loader/entries and
> /boot/boom/profiles as user data?

%config(noreplace) for profiles please.

For entries, I'm less certain, since we do not package any (only the
directory that contains them). I believe if a directory is not empty
after removing packaged files that RPM will leave it all behind.
 
> There are multiple reasons for that:
> 
> - If one for whatever reason removes boom package, shall we keep
> /boot/loader/entries? I think rather Yes.

Yes.
 
> - If there are multiple linux distribution installed, could they potentially
> fight over this directory and its content? Maybe...

Not if they actually comply with the standard that governs it:

  https://www.freedesktop.org/wiki/Specifications/BootLoaderSpec/

The whole entire point of that is that it is a shared, system-wide
/boot environment.

> - OsProfiles are similar and IMO even more relevant. User will likely need
> to change those (e.g at least remove rhgb and quiet from kernel cmdline,
> and/or add rd.luks.uuid), so if not data, we should treat them more like
> config files with backups, and we should not replace them on updates.

Yes: any that we actually provide (like the limited samples in RHEL)
ought to be %config(noreplace).

> - I am not sure OS/RPM would be happy about %config files in /boot :-|
>     - *TODO:* Test it even works!

Someone should tell the grub2 people:

$ rpm -qc grub2
/boot/grub2/grub.cfg
/boot/grub2/grubenv
/etc/grub2.cfg
 
Regards,
Bryn.


