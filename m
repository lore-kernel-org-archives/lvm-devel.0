From: Peter Rajnoha <prajnoha@redhat.com>
Date: Tue, 01 Oct 2013 13:24:59 +0200
Subject: lvmetad activation problem with MD devices
In-Reply-To: <524A744D.207@redhat.com>
References: <20130930203615.59bfd346@work.puleglot> <524A744D.207@redhat.com>
Message-ID: <524AB10B.2050705@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 10/01/2013 09:05 AM, Peter Rajnoha wrote:
> On 09/30/2013 06:36 PM, Alexander Tsoy wrote:
>> Commit 8d1d83504dcf9c86ad42d34d3bd0b201d7bab8f6 introduced the
>> following problem. If MD device is assembled in initramfs and some LVs
>> on it are not activated, then those LVs still not activated during
>> system boot.
> 
> Yes, sorry for the problem. I'm just working on a fix. The source of
> the problem here is that udev database is not handed over from initramfs
> for MD devices and so the udev state is simply lost. The state information
> we need is the MD activation state.

There's also a bug reported for this issue:

  https://bugzilla.redhat.com/show_bug.cgi?id=1011704

I've handed that over to dracut as we can solve this by adding a special
'OPTIONS+="db_persist"' udev rule to MD rules that are installed for MD
devices in initramfs. This is already done for device-mapper devices in
dracut.

The proposed patch is simple (also tested on my system where I reproduced
the original problem):

  https://bugzilla.redhat.com/attachment.cgi?id=805841

Peter


