Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.133.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1DFFA2E5406
	for <lvm-devel@lists.linux.dev>; Fri, 31 Oct 2025 19:30:19 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.133.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1761939022; cv=none; b=joGDAfvhTC9lVVxW9aJqfamADOg8kq4G2pWvdApFofMfN2RV5LWYdmQ/FgW1J6lRxTz80EB+ERD4Ro0glU4HgDi5auIoHZgyLCqTJRlid5JXXobK5OKTLibMny8jTXyztEg20q38qWJhZYvZEfDKZhfxsEgbtuK/IGVbm4cBgKc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1761939022; c=relaxed/simple;
	bh=HRT1zrlw67YT/v0zGnHpiKEt+Ry9RY8D6BYLFaVppGs=;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:
	 MIME-Version:Content-Type; b=bJGhjT4DcnDo9GujmhFGM2MdeQ+RB/KBB9M1HnKlLzetdAhxaGZptqnHvUZspCvyG6NNcv4I156eEyO9GaseMA39SzaehF9FjFGxgMDdOzTa6GPOhDaT55yTz682tT2pZfSKNw6Af3zgIs0rL+TiqtDEhZUjFsRvGH6qaIsCrUs=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=Ngld96Mp; arc=none smtp.client-ip=170.10.133.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="Ngld96Mp"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1761939019;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=SWgRT7WaYDoMlN1l4H+rmuJdT1C5jyRgb7Xd7l2YF2w=;
	b=Ngld96MpnUlCi+eolgTD+m2LU2D2nZkF/zcszh1k0UqWvDyskkKqv10CodhHd2QG7ih742
	neVr6GBgMvVQnn7moomdZyITgdJ+kIsFH4fjWe1Z8DZUOMsgNs6cwxWQhisRv1hun/gn5T
	+iU8Ur3D1We3Hp/r8o1kSvUbjJl/gR4=
Received: from mx-prod-mc-01.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-54-186-198-63.us-west-2.compute.amazonaws.com [54.186.198.63]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-668-lZ1S-KggMVeFoVz9gzeAxQ-1; Fri,
 31 Oct 2025 15:30:15 -0400
X-MC-Unique: lZ1S-KggMVeFoVz9gzeAxQ-1
X-Mimecast-MFC-AGG-ID: lZ1S-KggMVeFoVz9gzeAxQ_1761939012
Received: from mx-prod-int-08.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-08.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.111])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-01.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id 747B21954B00;
	Fri, 31 Oct 2025 19:30:11 +0000 (UTC)
Received: from [10.45.225.163] (unknown [10.45.225.163])
	by mx-prod-int-08.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id 2B2C118004D4;
	Fri, 31 Oct 2025 19:30:03 +0000 (UTC)
Date: Fri, 31 Oct 2025 20:29:58 +0100 (CET)
From: Mikulas Patocka <mpatocka@redhat.com>
To: Askar Safin <safinaskar@gmail.com>
cc: Dell.Client.Kernel@dell.com, brauner@kernel.org, dm-devel@lists.linux.dev, 
    ebiggers@kernel.org, kix@kix.es, linux-block@vger.kernel.org, 
    linux-btrfs@vger.kernel.org, linux-crypto@vger.kernel.org, 
    linux-lvm@lists.linux.dev, linux-mm@kvack.org, linux-pm@vger.kernel.org, 
    linux-raid@vger.kernel.org, lvm-devel@lists.linux.dev, agk@redhat.com, 
    msnitzer@redhat.com, milan@mazyland.cz, mzxreary@0pointer.de, 
    nphamcs@gmail.com, pavel@ucw.cz, rafael@kernel.org, ryncsn@gmail.com, 
    torvalds@linux-foundation.org
Subject: Re: [PATCH] pm-hibernate: flush block device cache when
 hibernating
In-Reply-To: <20251027084220.2064289-1-safinaskar@gmail.com>
Message-ID: <de1f0036-84f9-2923-2c0a-620e702d850b@redhat.com>
References: <03e58462-5045-e12f-9af6-be2aaf19f32c@redhat.com> <20251027084220.2064289-1-safinaskar@gmail.com>
Precedence: bulk
X-Mailing-List: lvm-devel@lists.linux.dev
List-Id: <lvm-devel.lists.linux.dev>
List-Subscribe: <mailto:lvm-devel+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:lvm-devel+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-Scanned-By: MIMEDefang 3.4.1 on 10.30.177.111



On Mon, 27 Oct 2025, Askar Safin wrote:

> Mikulas Patocka <mpatocka@redhat.com>:
> > Hi
> > 
> > Does this patch fix it?
> > 
> > Mikulas
> > 
> > 
> > From: Mikulas Patocka <mpatocka@redhat.com>
> > 
> > There was reported failure that hibernation doesn't work with 
> > dm-integrity. The reason for the failure is that the hibernation code 
> > doesn't issue the FLUSH bio - the data still sits in the dm-integrity 
> > cache and they are lost when poweroff happens.
> 
> I tested this patch in Qemu on current master (43e9ad0c55a3). Also I
> applied Mario's patch
> https://lore.kernel.org/linux-pm/20251026033115.436448-1-superm1@kernel.org/ .
> It is needed, otherwise you get WARNING when you try to hibernate.
> 
> The patch doesn't work.

Yes, I see - the problem is harder than I thought.

I've created two patches and I tested them that they work. So, you can try 
them.

Mikulas

