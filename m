From: ejt@redhat.com <ejt@redhat.com>
Date: Tue, 05 Oct 2010 13:54:23 +0100
Subject: [PATCH] dmeventd -R (restart; BZ 454618)
In-Reply-To: <87sk0kncit.fsf@twilight.int.mornfall.net.>
Message-ID: <874od0dclc.wl%ejt@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi Petr,

At Tue, 05 Oct 2010 12:45:46 +0200,
Petr Rockai wrote:
> Hi,
> 
> the attached patch implements dmeventd -R, which allows us to restart
> dmeventd without losing the monitoring state.

Do you think there are any unit tests you could write for this?  For
example you've made changes to libdevmapper-event.c, which being a
library is presumably amenable to being unit tested?

- Joe


