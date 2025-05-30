Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.133.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9FFE315746E
	for <lvm-devel@lists.linux.dev>; Fri, 30 May 2025 14:29:22 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.133.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1748615364; cv=none; b=mYw3SP9Sz1w0Dn8H66oUf7NhXku+GbFZNbwXkmuaKtnmR6Fx2P5ZF5yY5k5LyiAypkKGF1pRZz/Mv3rIMBj+K2AY/AlYmMmVN1h7uqrjeUrssdwfM5Hhj8UTYLJ84Z3I+vxy82peu7C8jvdC7zaqVHRri8VUEvP90V0xR/CvbDE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1748615364; c=relaxed/simple;
	bh=jXFpbjncDkqzLg9npQ/6vxATQnIOpvtFcFgL7CsdRek=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 In-Reply-To:Content-Type:Content-Disposition; b=PA9nU4A+4HCVPJHkOc/O//facPzUI7bJuxaMzKDbR7Lp5kkmCw8llFxK/Yoq/KqUjja64KwB6F2yfDfHGs3DWxUdtE7NCmMWEcizGm3RXdKK+MkX5rAVnKUOz+Y9fsg97S6grzzdeaR4qMYAlGD6LDsSeRrR0jWILegXjugaNNM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=SFh53LCz; arc=none smtp.client-ip=170.10.133.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="SFh53LCz"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1748615361;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=7mLx+pDQ93NWncjJmmJaQZF5JGbz+UqQID+FV13DRas=;
	b=SFh53LCz5pHsyP79sV5ASSgBdDJZmmh2e58zSWwqgFc97a8MGny5ZgjLGDwa9bH5SVlaxc
	vOAkvQ1upsdm52Q5PL2W9V73BUdglFWrkTg0tDBRDVXfLUuqcV5G8k5l83nxYHgkzMkZ8K
	EEXeV1Qzbdn0xDs2mFdiAbAxMqj1q64=
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com
 [209.85.221.72]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.3, cipher=TLS_AES_256_GCM_SHA384) id
 us-mta-556-32qsXMefMRiJeCPEx0Cr8g-1; Fri, 30 May 2025 10:29:17 -0400
X-MC-Unique: 32qsXMefMRiJeCPEx0Cr8g-1
X-Mimecast-MFC-AGG-ID: 32qsXMefMRiJeCPEx0Cr8g_1748615356
Received: by mail-wr1-f72.google.com with SMTP id ffacd0b85a97d-3a367b3bb78so1340765f8f.1
        for <lvm-devel@lists.linux.dev>; Fri, 30 May 2025 07:29:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1748615356; x=1749220156;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to;
        bh=7mLx+pDQ93NWncjJmmJaQZF5JGbz+UqQID+FV13DRas=;
        b=DiPDTE4JHKnAKItHt569xGFBZmqFQFt/1XPnsBelIXxW5AseAlgx6L0EV85MZidazo
         rEsMNqKx//spbU8Lo9mPfVGcKfRK2pu82qf+qMl7OqIiZaxyhB7K6HL1U1Sdl4KF8xte
         /XXD3NgYMb3cqDQhQDt/ZaDOpU7iJm+ylmw2+J8znXvKSpcDZVu7UCsquep9/5WEzrWJ
         NV//t23qmnuuzW30Z+rO4nay3XtKbIXl5L0FqPUr1d7v63qGovqLOlIdxT5DINpt9T8r
         2BXlFzfYjjv1Eb3F7bFyhTU7ceUKOvxURaA8GQOdi57f8L/dhmyWkOUmeiP8nPJE5CRH
         UPAg==
X-Gm-Message-State: AOJu0YxoS+gudUKTXqQua0tjE86Fir/x+IN3z4cg5EYhaV447wIaA9M2
	VynlhAmofwJJ7WQLiiim4tp617EjmSxvANh99BNapHZqkouRdh8AaP2HG7zlS2Curdhod7af7w2
	vxn3aIN0TIEusj+nqDO9/oQBJCbdUd8NTkDeJXY+09eT40rxPrQQs0jiO1yFXcVW9sfaLWg==
X-Gm-Gg: ASbGncs8aCq7IztD9EZF/hrChXZUDem2oUUbxP0AhQWtdyVfxXRUyXSBVQ6S0qq4gbo
	EBsWqzr1Rj49+8vjrPRSiVg8K2caYD7pCYFqvKFCaBa7JR43vHeqmrCfefHCJ7ktsC8czsHF0nh
	A4095/dRkywL1efG1/bSrrXTW9K+KTZZiXxn/UgIYszhLHVzfQGaOtgJOKzrao2+9SvoM8VCMl6
	2fbUh+kRm4Lk2Hrv/ZC01SxdXy1/uKCt0jubKJGAmk1BOrYro0D5XRgZH4lJ5Fgr134jgkahE18
	y5uvE9pMLqcKsJpgD3cAXNBaNHpU
X-Received: by 2002:a05:6000:188b:b0:3a3:6595:921f with SMTP id ffacd0b85a97d-3a4f7a9d628mr2849260f8f.41.1748615356040;
        Fri, 30 May 2025 07:29:16 -0700 (PDT)
X-Google-Smtp-Source: AGHT+IGVmHSiK0o+wEpPEGfu6zUrZVVdaiglz5er4i/bSHlLcBCi4w117QtrCeDj+FJUkx3uoe5obw==
X-Received: by 2002:a05:6000:188b:b0:3a3:6595:921f with SMTP id ffacd0b85a97d-3a4f7a9d628mr2849244f8f.41.1748615355645;
        Fri, 30 May 2025 07:29:15 -0700 (PDT)
Received: from redhat.com (128.19.187.81.in-addr.arpa. [81.187.19.128])
        by smtp.gmail.com with ESMTPSA id ffacd0b85a97d-3a4efe73eadsm4864325f8f.41.2025.05.30.07.29.15
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 30 May 2025 07:29:15 -0700 (PDT)
Date: Fri, 30 May 2025 15:29:13 +0100
From: "Bryn M. Reeves" <bmr@redhat.com>
To: Lakshmi Narasimhan Sundararajan <lns.myspace@gmail.com>
Cc: lvm-devel@lists.linux.dev
Subject: Re: Reg LVM PE Size and any limitations out of it
Message-ID: <aDnAuTyjzBFOG6Nc@redhat.com>
References: <CAHJKXw3v-UUwg1sAvYThJMZHi5GBvqvHpaDVSYaVcLGTe048Lg@mail.gmail.com>
Precedence: bulk
X-Mailing-List: lvm-devel@lists.linux.dev
List-Id: <lvm-devel.lists.linux.dev>
List-Subscribe: <mailto:lvm-devel+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:lvm-devel+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
In-Reply-To: <CAHJKXw3v-UUwg1sAvYThJMZHi5GBvqvHpaDVSYaVcLGTe048Lg@mail.gmail.com>
X-Mimecast-Spam-Score: 0
X-Mimecast-MFC-PROC-ID: 7GkRd5OUUEgFDJsDrmQ3GRfneOPBYBs5fZ43j0qlQZI_1748615356
X-Mimecast-Originator: redhat.com
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Thu, May 29, 2025 at 10:36:07PM +0530, Lakshmi Narasimhan Sundararajan wrote:
> 2) Is there any limit to the max number of PE in a VG?
> It is not called out in any man pages, but an internet search gave me
> a max of 16M extents in a VG. So here I am asking for clarification,
> and worried if there is such a limit, would it limit then the VG
> capacity expansion to only 16M * 4M ~ 64 T [It did not though, I
> experimentally validated it].
> 3) under what scenarios does one need to consider applying
> physicalextentsize explicitly?
> I am trying to understand the usecase this came about.

I think I see where this is coming from. The top result on Google (at
least for me, but I imagine from your post it's similar for others), is
this 11 year old SuperUser question thread:

  https://superuser.com/questions/735600/size-of-extent-on-lvm2

The poster incorrectly links to an old HP manual describing the limits
for the *HP-UX* Logical Volume Manager:

  https://docstore.mik.ua/manuals/hp-ux/en/5992-4589/apa.html

Although Linux LVM1 (long since ancient history) was inspired by the
HP-UX tools the tables at this URL have nothing to do with Linux LVM,
especially lvm2.

I agree this belongs in a man page, and shouldn't take so much searching
to track down.

Regards,
Bryn.

