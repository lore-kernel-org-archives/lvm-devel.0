From: Peter Rajnoha <prajnoha@redhat.com>
Date: Mon, 31 Jan 2011 12:37:59 +0100
Subject: [PATCH 04/24] Move add_dev_node to DM_DEVICE_RESUME
In-Reply-To: <56ba2c0e512202d41243c1ac211bb2efa399eb9b.1296391340.git.zkabelac@redhat.com>
References: <cover.1296391340.git.zkabelac@redhat.com>
	<56ba2c0e512202d41243c1ac211bb2efa399eb9b.1296391340.git.zkabelac@redhat.com>
Message-ID: <4D469F17.10109@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 01/30/2011 01:57 PM +0100, Zdenek Kabelac wrote:
> We need valid 'check_udev' for stacked ops processing.

This change would also remove this ugly part in
_create_and_load_v4 fn (the "create with table"):

  /* FIXME: Just for udev_check in dm_task_run. Can we avoid this? */
  task->event_nr = dmt->event_nr & DM_UDEV_FLAGS_MASK;
  task->cookie_set = dmt->cookie_set;

I had to copy this artificially for the DM_DEVICE_CREATE task
just to set the udev_check correctly in dm_task_run. Though,
unfortunately, it does not work when we have the CREATE, LOAD
and RESUME separated. So this fix is highly welcome!

Peter


