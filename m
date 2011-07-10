From: ben <benscott@nwlink.com>
Date: Sun, 10 Jul 2011 12:10:41 -0700
Subject: lvm2 2.02.86 error... udev problem?
In-Reply-To: <4E197D3E.3050300@redhat.com>
References: <201107092228.44493.benscott@nwlink.com>
	<4E197D3E.3050300@redhat.com>
Message-ID: <201107101210.41505.benscott@nwlink.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Sunday, July 10, 2011 03:21:50 AM Peter Rajnoha wrote:
> verify_udev_operations=1

That seems to help. Now I get this message:

# lvcreate  --name test --mirrors 1 --size 1g vg01
  /dev/mapper/vg01-test_mimage_0 not set up by udev: Falling back to direct 
node creation.
  /dev/mapper/vg01-test not set up by udev: Falling back to direct node 
creation.
  The link /dev/vg01/test should had been created by udev but it was not 
found. Falling back to direct link creation.
  Logical volume "test" created



