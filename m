From: Eric Ren <zren@suse.com>
Date: Mon, 7 Aug 2017 15:23:46 +0800
Subject: lvmlockd: adopt locks always failed
Message-ID: <107b2602-3918-fdbe-6645-da7a2c29e0e9@suse.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi David!

I'm testing "dlm + lvmlockd". Everything goes well so far, until I try 
the steps:
1. do everything to have a LV active on a shared VGs successfully;
2. kill lvmlockd on purpose;
3. restart lvmlockd with "--adopt 1".

Every time I get:
"""
Aug 07 13:09:14 tw1 lvmlockd[27299]: 1502082554 lvmlockd started
Aug 07 13:09:14 tw1 lvmlockd[27299]: 1502082554 adopt_locks failed, 
reset host
"""

After some debugging, I narrow down it here:

1.
adopt_locks()
{
...

        if (lm_support_dlm()) {
                 rv = lm_get_lockspaces_dlm(&ls_found); ====> OK.
                 if ((rv < 0) && (rv != -ECONNREFUSED))
                         goto fail;
         }

         if (lm_support_sanlock()) {
                 rv = lm_get_lockspaces_sanlock(&ls_found);       ====> 
rv gets -2
                 if ((rv < 0) && (rv != -ECONNREFUSED))
                         goto fail;
         }
...
}

2.
sanlock_get_lockspaces()
{
...
         rv = connect_socket(&fd);
         if (rv < 0)
                 return rv;                 ===> it return -2, because 
sanlock plugin is not running
...
}

The problem here seems we should not ask sanlock for left lockspaces 
when it's not running?

Thanks in advance!
Eric


