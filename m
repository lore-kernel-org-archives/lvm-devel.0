Received: from verein.lst.de (verein.lst.de [213.95.11.211])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 823497E599;
	Thu, 29 Feb 2024 13:21:00 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=213.95.11.211
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1709212862; cv=none; b=pkClSgMqpI2joxksHnbHhQVLx7yJipX/dc3qLLoJu7vJk/A9EBOf2MtA/+UBVWOzLz0afcVc8rzxBcl+8THMmV9dggVcv9rOAHJMoNi8ostO3nYvw2D58vdxj/pW+nl6UsqebNtIOfc5I/EI9ZA39HhvprkPTKgmduzdkmoGdKI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1709212862; c=relaxed/simple;
	bh=M3sRBoBSnkBK96U6qK6wazB9MSGZuSvjzJj0jFQvm4c=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=MdMevmIAbOp9f1cFH+1z3s+scUe1XT1wEQVizSpSi9VFaozQWsPSGnwNd6O+mwsRXj2JvguDPho4usdALsI96QlihbY08ukXTw4GTUrTyVeN5h1zU8IaFbzoW8kifBEUgn8PrtLQEdnN+1e5S1dHEZod6ScMtNBLtEifB7/xcYg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de; spf=pass smtp.mailfrom=lst.de; arc=none smtp.client-ip=213.95.11.211
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=lst.de
Received: by verein.lst.de (Postfix, from userid 2407)
	id CC6AD68BEB; Thu, 29 Feb 2024 14:20:52 +0100 (CET)
Date: Thu, 29 Feb 2024 14:20:52 +0100
From: Christoph Hellwig <hch@lst.de>
To: Song Liu <song@kernel.org>
Cc: Christoph Hellwig <hch@lst.de>, Mike Snitzer <snitzer@kernel.org>,
	Benjamin Marzinski <bmarzins@redhat.com>, Xiao Ni <xni@redhat.com>,
	Zdenek Kabelac <zkabelac@redhat.com>, Jens Axboe <axboe@kernel.dk>,
	Mikulas Patocka <mpatocka@redhat.com>, Yu Kuai <yukuai3@huawei.com>,
	dm-devel@lists.linux.dev, linux-block@vger.kernel.org,
	linux-raid@vger.kernel.org, lvm-devel@lists.linux.dev
Subject: Re: atomic queue limit updates for stackable devices
Message-ID: <20240229132052.GA6858@lst.de>
References: <20240223161247.3998821-1-hch@lst.de> <ZdjXsm9jwQlKpM87@redhat.com> <ZdjYJrKCLBF8Gw8D@redhat.com> <20240227151016.GC14335@lst.de> <Zd38193LQCpF3-D0@redhat.com> <20240227151734.GA14628@lst.de> <Zd4BhQ66dC_d7Mn0@redhat.com> <CAPhsuW69mM3tEBR=SgKy_SYE+NUsNO+8H6toyk+5mKcSfGMjmg@mail.gmail.com> <20240228195632.GA20077@lst.de> <CAPhsuW5c5o8JS9T8CCGU811jpxrbepjJHnYpDbge+1rT6j8NbA@mail.gmail.com>
Precedence: bulk
X-Mailing-List: lvm-devel@lists.linux.dev
List-Id: <lvm-devel.lists.linux.dev>
List-Subscribe: <mailto:lvm-devel+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:lvm-devel+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPhsuW5c5o8JS9T8CCGU811jpxrbepjJHnYpDbge+1rT6j8NbA@mail.gmail.com>
User-Agent: Mutt/1.5.17 (2007-11-01)

On Wed, Feb 28, 2024 at 06:02:33PM -0800, Song Liu wrote:
> md-6.9 branch doesn't have all the fixes, as some recent fixes
> are routed via the md-6.8 branch. You can try on this branch, which
> should provide a better base line. The set applies cleanly on this
> branch.
> 
> https://git.kernel.org/pub/scm/linux/kernel/git/song/md.git/log/?h=md-6.9-for-hch

This branch crashes for me when running the lvm2 test suite:

###      running: [ndev-vanilla] shell/lvconvert-raid-reshape.sh  0:26.281[
1108.566441] md: mdX: re.
[ 1108.694826] md/raid:mdX: device dm-67 operational as raid disk 0
[ 1108.695034] md/raid:mdX: device dm-69 operational as raid disk 1
[ 1108.695360] md/raid:mdX: device dm-71 operational as raid disk 2
[ 1108.695532] md/raid:mdX: device dm-73 operational as raid disk 3
[ 1108.696468] md/raid:mdX: raid level 5 active with 4 out of 4 devices,
algorithm 2
[ 1108.696801] device-mapper: raid: raid456 discard support disabled due to
discard_zeroes_data unce.
[ 1108.697059] device-mapper: raid: Set dm-raid.devices_handle_discard_safely=Y
to override.
[ 1109.129345] md/raid:mdX: device dm-67 operational as raid disk 0
[ 1109.129550] md/raid:mdX: device dm-69 operational as raid disk 1
[ 1109.129720] md/raid:mdX: device dm-71 operational as raid disk 2
[ 1109.129887] md/raid:mdX: device dm-73 operational as raid disk 3
[ 1109.130775] md/raid:mdX: raid level 5 active with 4 out of 4 devices,
algorithm 5
[ 1109.134517] device-mapper: raid: raid456 discard support disabled due to
discard_zeroes_data unce.
[ 1109.135207] device-mapper: raid: Set dm-raid.devices_handle_discard_safely=Y
to override.
[ 1112.713392] md: reshape of RAID array mdX
[ 1112.828252] BUG: kernel NULL pointer dereference, address: 0000000000000088
[ 1112.828467] #PF: supervisor read access in kernel mode
[ 1112.828613] #PF: error_code(0x0000) - not-present page
[ 1112.828755] PGD 0 P4D 0 
[ 1112.828829] Oops: 0000 [#2] PREEMPT SMP NOPTI
[ 1112.828955] CPU: 1 PID: 1785 Comm: kworker/1:2 Tainted: G      D W
6.8.0-rc3+ #2235
[ 1112.829181] Hardware name: QEMU Standard PC (Q35 + ICH9, 2009), BIOS
1.16.2-debian-1.16.2-1 04/014
[ 1112.829422] Workqueue: md_misc md_start_sync
[ 1112.829542] RIP: 0010:md_start_sync+0x66/0x2e0
[ 1112.829666] Code: c0 0f 85 ef 00 00 00 48 83 bb 50 fd ff ff ff 0f 84 9d 01
00 00 48 8b 83 90 fb f5
[ 1112.830197] RSP: 0018:ffffc900016dbe28 EFLAGS: 00010213
[ 1112.830337] RAX: 0000000000000000 RBX: ffff888115a224d0 RCX:
0000000000000000
[ 1112.830527] RDX: 0000000000000000 RSI: ffffffff8301a09e RDI:
00000000ffffffff
[ 1112.830717] RBP: ffff888115a222b0 R08: 0000000000000001 R09:
0000000000000000
[ 1112.830906] R10: ffffc900016dbe28 R11: 0000000000000001 R12:
ffff888115a222b1
[ 1112.831094] R13: ffff888115a22058 R14: 0000000000000000 R15:
ffffffff81190681
[ 1112.831285] FS:  0000000000000000(0000) GS:ffff8881f9d00000(0000)
knlGS:0000000000000000
[ 1112.831497] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[ 1112.831653] CR2: 0000000000000088 CR3: 000000010426c000 CR4:
0000000000750ef0
[ 1112.831879] PKRU: 55555554
[ 1112.831954] Call Trace:
[ 1112.832024]  <TASK>
[ 1112.832085]  ? __die+0x1e/0x60
[ 1112.832173]  ? page_fault_oops+0x154/0x450
[ 1112.832286]  ? do_user_addr_fault+0x69/0x7e0
[ 1112.832403]  ? exc_page_fault+0x6d/0x1c0
[ 1112.832512]  ? asm_exc_page_fault+0x26/0x30
[ 1112.832628]  ? process_one_work+0x171/0x4a0
[ 1112.832743]  ? md_start_sync+0x66/0x2e0
[ 1112.832849]  ? md_start_sync+0x35/0x2e0
[ 1112.832957]  process_one_work+0x1d8/0x4a0
[ 1112.833066]  worker_thread+0x1ce/0x3b0
[ 1112.833169]  ? wq_sysfs_prep_attrs+0x90/0x90
[ 1112.833285]  kthread+0xf2/0x120
[ 1112.833374]  ? kthread_complete_and_exit+0x20/0x20
[ 1112.833504]  ret_from_fork+0x2c/0x40
[ 1112.833616]  ? kthread_complete_and_exit+0x20/0x20
[ 1112.833746]  ret_from_fork_asm+0x11/0x20
[ 1112.833855]  </TASK>
[ 1112.833918] Modules linked in: dm_raid i2c_i801 crc32_pclmul i2c_smbus [last
unloaded: scsi_debug]
[ 1112.834156] CR2: 0000000000000088
[ 1112.834248] ---[ end trace 0000000000000000 ]---
[ 1112.834373] RIP: 0010:remove_and_add_spares+0x72/0x2f0
