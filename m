Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.133.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id F2318262FCB
	for <lvm-devel@lists.linux.dev>; Thu,  7 Aug 2025 14:08:10 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.133.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1754575692; cv=none; b=tDzK26lK1PjSGKV3aNibp8DZHfY8WT/2uZg82SZj/Fm9cd2XaSlpTzgpHHRB01uMHhOTmy9W2jgeLNkhhGYCofVdj7AKxBQonwiGOPUTBbtsjYHRAOdd3m+DDTe/7hMsqmYLrL6307+va6TXHI7Jd0rAslVY4h0pZA06NlGhvSY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1754575692; c=relaxed/simple;
	bh=1VjpzIRNoHSeB453wVUCdndw0f2m52DvpKKG3JJdT8I=;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:
	 MIME-Version:Content-Type; b=CTOcRrD18SOWNP63o4P4r9R8ae4VgyRplR5+BwtZreGqPwZDgGVeWLxTxFUVf/hFrhBtSYgigEMIuOdhwqvckOl/vMpX+0sEUhnL+gm0jMJRb3NTET+ZyI4hB0TBc10VWA/zpMdsk7jl2/m4O5qlPUWuQzYHTasZbKwrXY+uPCI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=BwqGN0iy; arc=none smtp.client-ip=170.10.133.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="BwqGN0iy"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1754575689;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=BaIvem0b8KUJqv49KiSMFYb0UY+BvekbdmOKe0MMGuY=;
	b=BwqGN0iyIf9lZ7sdYPgJ2QtEvZ/c47T0J2ZgvM+kYqhZ/2O52RfvAJrJP+hkdHJNtnIPBk
	Lptrv9NpPwV7b2znfK2n5z3szFQTwAEdz1UI/oL7a440bFeUAGRCxjTRtb3dhd3uI8mlCq
	ldtHnQbmYoHi83sCNCf7kcJ3XbzwZLE=
Received: from mx-prod-mc-08.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-35-165-154-97.us-west-2.compute.amazonaws.com [35.165.154.97]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-648-phh3_JCQNQa4mh8p78gtgg-1; Thu,
 07 Aug 2025 10:08:06 -0400
X-MC-Unique: phh3_JCQNQa4mh8p78gtgg-1
X-Mimecast-MFC-AGG-ID: phh3_JCQNQa4mh8p78gtgg_1754575685
Received: from mx-prod-int-05.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-05.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.17])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-08.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id 4B4641800357;
	Thu,  7 Aug 2025 14:08:04 +0000 (UTC)
Received: from [10.22.80.50] (unknown [10.22.80.50])
	by mx-prod-int-05.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id 970D51954185;
	Thu,  7 Aug 2025 14:08:00 +0000 (UTC)
Date: Thu, 7 Aug 2025 16:07:53 +0200 (CEST)
From: Mikulas Patocka <mpatocka@redhat.com>
To: Stuart D Gathman <stuart@gathman.org>
cc: John Stoffel <john@stoffel.org>, Peter Rajnoha <prajnoha@redhat.com>, 
    Zdenek Kabelac <zkabelac@redhat.com>, 
    Heinz Mauelshagen <heinzm@redhat.com>, 
    David Teigland <teigland@redhat.com>, linux-lvm@lists.linux.dev, 
    lvm-devel@lists.linux.dev
Subject: Re: [PATCH] fix random failures in shell/integrity.sh
In-Reply-To: <65919799-842c-9428-8bfc-5c1c0671338@gathman.org>
Message-ID: <36d044e7-75f0-9b53-8969-0423fade7ea7@redhat.com>
References: <06d25902-7239-1fc7-ec3b-1798332c3315@redhat.com> <26771.51188.491376.658337@quad.stoffel.home> <65919799-842c-9428-8bfc-5c1c0671338@gathman.org>
Precedence: bulk
X-Mailing-List: lvm-devel@lists.linux.dev
List-Id: <lvm-devel.lists.linux.dev>
List-Subscribe: <mailto:lvm-devel+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:lvm-devel+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
X-Scanned-By: MIMEDefang 3.0 on 10.30.177.17
X-Mimecast-Spam-Score: 0
X-Mimecast-MFC-PROC-ID: FBJBPeuQFrXSMtVblu_pMyk-S0P4Ut-JPIa7s6oE5Rw_1754575685
X-Mimecast-Originator: redhat.com
Content-Type: text/plain; charset=US-ASCII



On Thu, 7 Aug 2025, Stuart D Gathman wrote:

> On Wed, 6 Aug 2025, John Stoffel wrote:
> 
> > > > > > > "Mikulas" == Mikulas Patocka <mpatocka@redhat.com> writes:
> > 
> > > The problem is that the raid1 implementation may freely choose which leg
> > > to read from. If it chooses to read from the non-corrupted leg, the
> > > corruption is not detected, the number of mismatches is not incremented
> > > and the test reports this as a failure.
> > 
> > So wait, how is integrity supposed to work in this situation then?  In
> > real life?  I understand the test is hard, maybe doing it in a loop
> > three times?  Or configure the RAID1 to prefer one half over another
> > is the way to make this test work?

If you want to make sure that you detect (and correct) all mismatches, you 
have to scrub the raid array.

> Linux needs an optional parameter to read() syscall that is "leg index"
> for the blk interface.  Thus, btrfs scrub can check all legs, and this
> test can check all legs.  Filesystems with checks can repair corruption
> by rewriting the block after finding a leg with correct csum.
> 
> This only needs a few bits (how many legs can there be?), so can go in
> the FLAGS argument.

I think that adding a new bit for the read syscalls is not a workable 
solition. There are so many programs using the read() syscall and teaching 
them to use this new bit is impossible.

Mikulas

