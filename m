From: Alasdair G Kergon <agk@redhat.com>
Date: Mon, 1 Mar 2010 13:15:32 +0000
Subject: [PATCH] Make use of new DM_UEVENT_GENERATED_FLAG in dm ioctl
In-Reply-To: <4B8B7E2D.4060704@redhat.com>
References: <4B8B7E2D.4060704@redhat.com>
Message-ID: <20100301131532.GO560@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Mon, Mar 01, 2010 at 09:43:25AM +0100, Peter Rajnoha wrote:
> We need to know whether we should wait for any uevent or not when
> using udev_sync. A patch was posted recently that changed the way
> uevents are sent on dm device resume - it is sent only if the device
> has been suspended before.
 
> This is quite important to prevent infinite waiting for any
> non-existent notifications.
 
Yes - I think it probably makes sense to have this independent notification
that an actionable udev event was generated, rather than userspace having to
deduce this from its knowledge of the internal kernel logic.

Alasdair


