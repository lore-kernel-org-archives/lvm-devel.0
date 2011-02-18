From: Alasdair G Kergon <agk@redhat.com>
Date: Fri, 18 Feb 2011 16:41:41 +0000
Subject: [PATCH] Add systemd service file
In-Reply-To: <20110218163117.GD5980@genesis.frugalware.org>
References: <20110218163117.GD5980@genesis.frugalware.org>
Message-ID: <20110218164141.GG28729@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Could you explain a bit more how the sequence of activations will work?

vgchange -ay is rather crude and not what everyone will require.

- Where do people configure (or have auto-detected) the LVs they want activated
at boot?

- How do clustered VGs fit in?  (look at the existing init script)

- How do stacked devices fit in? 

Alasdair


