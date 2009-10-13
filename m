From: Alasdair G Kergon <agk@redhat.com>
Date: Tue, 13 Oct 2009 12:39:37 +0100
Subject: [PATCH 2/2] make the device node creation more atomic
In-Reply-To: <ba48c85095b6949cf2ad2a3c414c324e1452d04a.1255411548.git.fdinitto@redhat.com>
References: <65a458b2db3a9e79318281c38f94672e4cc585dc.1255411547.git.fdinitto@redhat.com>
	<ba48c85095b6949cf2ad2a3c414c324e1452d04a.1255411548.git.fdinitto@redhat.com>
Message-ID: <20091013113937.GH16950@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Tue, Oct 13, 2009 at 07:28:38AM +0200, Fabio M. Di Nitto wrote:
> +	_build_dev_path(tmppath, sizeof(tmppath), ".XXXXXX");
> +	mktemp(tmppath);

Unfortunately this still looks to have races because the actual lock is
not acquired by the mktemp function, but only later, and there is no
retry mechanism in this patch - if two parallel mktemps picked the same
name the code would fail, introducing a failure mode that is not present
in the existing code.

Normally you would use mkstemp rather than mktemp.

Options: 
  (1) introduce a ugly collision detection + retry mechanism;
  (2) use mkstemp() to lock a related filename in a new namespace
e.g. .XXXXXX.lock and .XXXXXX.node and do the mknod on .XXXXXX.node
while using the unique .XXXXXX.lock regular file as an exclusive lock;
  (3) use the existing create_temp_name() function (moving it to libdm)
or write a variant that does mknod() checking for EEXIST instead of open();
  (4) find some other solution.

My current preferrence would be (3) - to encapsulate the functionality
required in a new 'create_temp_node' function.

Alasdair


