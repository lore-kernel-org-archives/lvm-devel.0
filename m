From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Tue, 11 Feb 2014 11:33:17 +0100
Subject: dmeventd generates segfault when creating snapshots
In-Reply-To: <20140210203415.7529.DDAE3F33@valinux.co.jp>
References: <20140210203415.7529.DDAE3F33@valinux.co.jp>
Message-ID: <52F9FC6D.6090708@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 10.2.2014 12:34, Chiyohiko Morita napsal(a):
> 
> (I'm not on this list; please Cc me)
> 
> With a high load, the dmeventd daemon sometimes generates
> a segmentation violation when createing a lvm-snapshot.
> 
> In _register_for_event(), it may take 10 or more seconds between
> calling _register_for_timeout() and _create_thread().
> (Please refer to the following _register_for_timeout().)
> 
> If the _timeout_thread thread calls pthread_kill() before
> _create_thread() is called, dmeventd will generate segfault.
> This is because the value of thread->thread is still NULL.
> (Please refer to the following _timeout_thread().)
> 
> A related source code and coredump are shown below.
> 

Could you please open regular  lvm2 bugzilla
(at   http://bugzilla.redhat.com/   - use Fedora Rawhide in case you don't
have match for your distro)

Attach all your information provided here in your email.

Add info from 'vgs, lvs -a, pvs' and your in-use lvm.conf
version of your lvm2 package,
how many volumes are active.

Thank you

Zdenek


