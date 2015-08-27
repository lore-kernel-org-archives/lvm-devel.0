From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Thu, 27 Aug 2015 13:59:14 +0200
Subject: [PATCH] libdm-iface: not output error message inside retry loops
In-Reply-To: <1440664241-6149-1-git-send-email-lwang@suse.com>
References: <1440664241-6149-1-git-send-email-lwang@suse.com>
Message-ID: <55DEFB92.5020106@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 27.8.2015 v 10:30 Liuhua Wang napsal(a):
>      To avoid noisy error message being output inside retry loops
>      in case of remove failure because device busy.
> ---

Hi

It's in fact made 'noisy' intentionally - we normally should detect whether 
retry makes sense - so  what are the conditions when you experience this problem ?

Common scenario:

The major reason for retry is 'unpredictable'  udev event processing
i.e. you run  'umount' -> fires watch-rule -> lvremove  could have failed - 
retry fixes this problem.


Regards

Zdenek


