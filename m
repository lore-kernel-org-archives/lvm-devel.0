Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.129.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E66B932ABFD
	for <lvm-devel@lists.linux.dev>; Mon, 24 Nov 2025 19:52:02 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.129.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1764013925; cv=none; b=oxUwO0roB1jb+omJQPk1mfLi1QwETfVRqCfCcacBK+XcPmKFvpVWGirusu5LB3cu5aWq/TwPfClBs1HgY1h2dtXE6sISCTHTrbeaQqoVSbZyzN6mY2DRQ3zrOcushtF5U5nL0ZeHaktnMdNtbEMGJHviaXHRufG+eNypP5Hf8fY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1764013925; c=relaxed/simple;
	bh=kwrO+Mnb6L8qVWUtNbvySCVYiWHMfhYzBQP6+X0oeys=;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:
	 MIME-Version:Content-Type; b=Vha5RRkpgQa6KeX10Cy5VFn4v61XvOkRIe4p3Ip4chXrh6Ebgii4cjcW0d4kOP/9KUlTQ+uNIMzY0XViG2kdndZBzPSKHbI9K0sNfdSHxAzWaSwQdhYIdoIcvHSMopIpLe90JvwXGxKrc+vlZP+wC26yGBR4bRkBi3ZkSI1Y1pY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=a5LY26iG; arc=none smtp.client-ip=170.10.129.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="a5LY26iG"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1764013921;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=57MP1DopHTQAggif2CcNJ9umqlpooR5GfWP71F0mvdU=;
	b=a5LY26iGWN5G2pChfF0u4KKTGeOiH4oLR5V15ljywutINHSpYhAutg45vSga6ectwhyypT
	RnGpshRbIe+2WFUZbZR+mb6cqhlwULVko+wj5kZhuu0kJtII/r5GbLe9VT7jfhZvHnXJly
	fO6Ij72eMMfQgjeXOLGT47N8bJCjWog=
Received: from mx-prod-mc-08.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-35-165-154-97.us-west-2.compute.amazonaws.com [35.165.154.97]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-633-uL-TaeAMNeaDna5HDm89iw-1; Mon,
 24 Nov 2025 14:51:35 -0500
X-MC-Unique: uL-TaeAMNeaDna5HDm89iw-1
X-Mimecast-MFC-AGG-ID: uL-TaeAMNeaDna5HDm89iw_1764013886
Received: from mx-prod-int-06.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-06.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.93])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-08.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id 6CE861800447;
	Mon, 24 Nov 2025 19:51:25 +0000 (UTC)
Received: from [10.44.33.72] (unknown [10.44.33.72])
	by mx-prod-int-06.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id 8EDD918004D8;
	Mon, 24 Nov 2025 19:51:18 +0000 (UTC)
Date: Mon, 24 Nov 2025 20:51:16 +0100 (CET)
From: Mikulas Patocka <mpatocka@redhat.com>
To: Askar Safin <safinaskar@gmail.com>
cc: Dell.Client.Kernel@dell.com, agk@redhat.com, brauner@kernel.org, 
    dm-devel@lists.linux.dev, ebiggers@kernel.org, kix@kix.es, 
    linux-block@vger.kernel.org, linux-btrfs@vger.kernel.org, 
    linux-crypto@vger.kernel.org, linux-lvm@lists.linux.dev, 
    linux-mm@kvack.org, linux-pm@vger.kernel.org, linux-raid@vger.kernel.org, 
    lvm-devel@lists.linux.dev, milan@mazyland.cz, msnitzer@redhat.com, 
    mzxreary@0pointer.de, nphamcs@gmail.com, pavel@ucw.cz, rafael@kernel.org, 
    ryncsn@gmail.com, torvalds@linux-foundation.org
Subject: Re: [PATCH 1/2] pm-hibernate: flush disk cache when suspending
In-Reply-To: <20251122224748.3724202-1-safinaskar@gmail.com>
Message-ID: <4085e0de-30f5-870c-ff82-5a293fe8ac73@redhat.com>
References: <c44942f2-cf4d-04c2-908f-d16e2e60aae2@redhat.com> <20251122224748.3724202-1-safinaskar@gmail.com>
Precedence: bulk
X-Mailing-List: lvm-devel@lists.linux.dev
List-Id: <lvm-devel.lists.linux.dev>
List-Subscribe: <mailto:lvm-devel+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:lvm-devel+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-Scanned-By: MIMEDefang 3.4.1 on 10.30.177.93



On Sun, 23 Nov 2025, Askar Safin wrote:

> Mikulas Patocka <mpatocka@redhat.com>:
> > [PATCH 1/2] pm-hibernate: flush disk cache when suspending
> > 
> > There was reported failure that suspend doesn't work with dm-integrity.
> > The reason for the failure is that the suspend code doesn't issue the
> > FLUSH bio - the data still sits in the dm-integrity cache and they are
> > lost when poweroff happens.
> 
> I tested this patchset (in Qemu). It works.
> 
> Here is script I used for testing:
> 
> https://zerobin.net/?66669be7d2404586#xWufhCq7zCoOk3LJcJCj7W4k3vYT3U4vhGutTN3p8m0=
> 
> Here are logs:
> 
> https://zerobin.net/?5d4a2abbad751890#WMcQl4FAZC9KqcAuJU3TSVr7wuVnPFwI7dlinA9QHOo=
> 
> Tested-By: Askar Safin <safinaskar@gmail.com>
> 
> There was no any reason to wait for me. You could easily test using script above.
> 
> Also: Linux shows this scary message when booting in Qemu:
> 
> [    0.512581] sd 0:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
> 
> So, FUA is not supported? Does it mean that this patch is wrong, and works purely
> by chance?

If FUA is not supported by a disk, the kernel would send a flush request 
after the write request with the FUA flag. There's no problem with that - 
the cache will be flushed correctly.

Mikulas

> -- 
> Askar Safin
> 

