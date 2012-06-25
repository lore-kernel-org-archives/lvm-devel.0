From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Mon, 25 Jun 2012 12:27:05 +0200
Subject: master - dev-io: open device read-only to obtain readahead value
In-Reply-To: <20120625095647.C465B1706@lists.fedorahosted.org>
References: <20120625095647.C465B1706@lists.fedorahosted.org>
Message-ID: <4FE83CF9.9010805@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 25.6.2012 11:56, Peter Rajnoha napsal(a):
>
> dev-io: open device read-only to obtain readahead value
>
> There's no need to have the device open RW while obtaining the readahead value.
> The RW open used before caused the CHANGE udev event to be generated if the
> WATCH udev rule was set for the underlying device (and that is normally the
> case both for non-dm and dm devices by default).
>
> This did not cause any problems before since we were not interested in
> *underlying* devices. However, with upcoming changes (autoactivation), we're
> watching for events on underlying devices marked as PVs and such a spurious
> event could cause the autoactivation code to be triggered. So when trying
> to deactivate the volume, we could end up with immediate activation just after
> that because of the CHANGE event originated in the WATCH udev rule since the
> underlying device was open RW during the deactivation process.
>
> Though maybe a better solution would be to completely filter such spurious
> events out of the autoactivation process somehow, it's still useful if there
> are as least spurious events generated as possible in the system itself.


Which should be further fixed to use sysfs improved libdm method.

Zdenek


