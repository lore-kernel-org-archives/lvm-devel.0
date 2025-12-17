Received: from mail-lf1-f45.google.com (mail-lf1-f45.google.com [209.85.167.45])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 395AE3112B7
	for <lvm-devel@lists.linux.dev>; Wed, 17 Dec 2025 23:18:46 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.167.45
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1766013528; cv=none; b=VLReMifKl07/E2m9p8KZNie8GNc5fQnnvcnHVjbobucfkx91BI4CCqsdluTMa3tDG8N3YKWrxfp1QlkNLRs9hsmy4euyjWQmRDhHa26Ieui7dBj+w6yoBE1UJon2HP6XYX/xtuMS6OexNKQl7smCWNMkP+VazvsVYTBFf9NpjBs=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1766013528; c=relaxed/simple;
	bh=C1X5R0T9A6CrUnxpIm/QVXVuRULmzTp597QRk97zyjM=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=OX2bq2e0Cn+5T4JfYY83/QUXoQU0tS86k8eY7YP5kd93XhDiLcqmAzEEYvvkn/oi5VbD0o1WxEj4zgqW3zxCzaNvklOdgH8hdlqbPOUHLNiPgnPpJQDvt62Y+UzznHFEmEfREZVPMvKBBco6pFZQh9aUpJ3cFDJXBTtG2sURikA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=m712Gq8a; arc=none smtp.client-ip=209.85.167.45
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="m712Gq8a"
Received: by mail-lf1-f45.google.com with SMTP id 2adb3069b0e04-595910c9178so14321e87.1
        for <lvm-devel@lists.linux.dev>; Wed, 17 Dec 2025 15:18:46 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1766013524; x=1766618324; darn=lists.linux.dev;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to;
        bh=AZvc3rVI0di0d/Re6Le5Bvc+vMvJtdhpmIxMnxjb6tA=;
        b=m712Gq8aXTeHqrdEiYNYZFwuKqU3i5ANi2LJWDCUQ3M7qvbUpL0v5Aac8cybpVRT03
         CXXtchIa67nua+K1DRpB9VLCoMmwPelUA0Py9ZfDwRXB9AxjAxZW4aC3+V72V/Z68x1e
         NOu3tIfRsNMPJUIF8xtp0jWKkjAjbgNSrTzdf/HktUMzKxqD50Xdc2nMS+OBhgWPLdEL
         X/EHfhkAJxE67CEKjZZ7kMoDXF8hB9GHzoUn236ubWonYl3tXjDEFS8H2lQxufINlxz0
         Th6ni8Eq0T9GzySne83SID3LMO4n9ftrC/WSCkzCVyPN75z7FJQT6aXvisQuoPVDQKul
         UdQg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1766013524; x=1766618324;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to;
        bh=AZvc3rVI0di0d/Re6Le5Bvc+vMvJtdhpmIxMnxjb6tA=;
        b=nP4owpBADa7Pbg1Jgd33Yix6XcnX8eZZB3ihtWJX5aQC/eUcxJMQY1olniGoXZQpc3
         +CDWhnjWDj4vVIZwpq097JQeoJrFO6JRgeDH2CsyXiV3jPA7AgwwC87C7iyWrnOQoD5u
         uu8QQEj0xfydrMtLoQZNtvXliFTRbYD2uqCj3sDliNWb3o4dBOGXsha3MDQVMad6N8w8
         l1dNEa0apoyYAnN+cEPmBxUt8TPoXYS3COrMCBpEKjR8+xfQVMXvZn2FewwjVi3XEkz4
         tXLGbgAb+lDFcfp5KrknwsYM8YoGXkVBt9YSrlAKUvarf8o62YQRPCUXTFLqNKTgMSNR
         xgCg==
X-Forwarded-Encrypted: i=1; AJvYcCUbhvGSoKV2N86wc/A2+w6OFipOu25uqBEY8HkMNYrqkAEc3W9hej1YBkEwEYDJ0CiBO7LexCBCjnE=@lists.linux.dev
X-Gm-Message-State: AOJu0YwDKHE8lam9OUs8Vq7nEOl5TG5DXJJAJFxwJlEOv7IB3td/PLcQ
	IspzNpwhiEOpEIKy+vWQyJdsgwgfAt1sZvBjxsQR1677gX/Cxe+cnxyF
X-Gm-Gg: AY/fxX4SRJ+z4FzjM191WIFmLIq1oJVuOpjNZaXaYspF68D53onPcFFSOKBT6r1uvC6
	qnBjFMgR5c1gsEmknfzoX/i+8e2xF8qUcnuY/I1WhyVFJBd+VgnDgkQ4gvFseieKOx727Xs8jfC
	lCC28B/iEPFGPSWrhEQ7WmkCS2KjdPER6DJ3Cyb90FHJJO1B3/bnQO7Vl2a7AYNVPNEHqSYPuvv
	7Aeg50EFLniHcNc725qHCDSWFD+z0P1xtomPLxw5KaO+RVYigRTLCHabM4yR+BwukxrKm9VnDbK
	Qvr8YMnqErckQYnJtNEa59NXDd9tgQ6rfQX91xK+lX5L7b4CLcta9Rp3s9ivG0OYefzRzG6oUp4
	QJjwlVsSarpu+jW/5z3lQ83qogPFhAZqdep1XowllHQYpFvuciCVtZpjpg9WyEHyprR4Mvc1UeU
	AgI+9/LmRp
X-Google-Smtp-Source: AGHT+IFoFgIAi9PMNEfIKCxeozWxswujwd1S6MJvMAmdk00BzJYAqN7Mqo6fE4Jz6OZ88KHyEwKy2w==
X-Received: by 2002:a05:6512:3ba2:b0:598:edd4:d68 with SMTP id 2adb3069b0e04-598faa5a3bamr5789014e87.28.1766013524025;
        Wed, 17 Dec 2025 15:18:44 -0800 (PST)
Received: from localhost ([194.190.17.114])
        by smtp.gmail.com with UTF8SMTPSA id 38308e7fff4ca-381134b5011sm2807821fa.3.2025.12.17.15.18.42
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Wed, 17 Dec 2025 15:18:42 -0800 (PST)
From: Askar Safin <safinaskar@gmail.com>
To: mpatocka@redhat.com
Cc: Dell.Client.Kernel@dell.com,
	dm-devel@lists.linux.dev,
	linux-block@vger.kernel.org,
	linux-btrfs@vger.kernel.org,
	linux-crypto@vger.kernel.org,
	linux-lvm@lists.linux.dev,
	linux-mm@kvack.org,
	linux-pm@vger.kernel.org,
	linux-raid@vger.kernel.org,
	lvm-devel@lists.linux.dev,
	pavel@ucw.cz,
	rafael@kernel.org,
	gmazyland@gmail.com
Subject: Re: [RFC PATCH 2/2] swsusp: make it possible to hibernate to device mapper devices
Date: Thu, 18 Dec 2025 02:18:37 +0300
Message-ID: <20251217231837.157443-1-safinaskar@gmail.com>
X-Mailer: git-send-email 2.47.3
In-Reply-To: <b32d0701-4399-9c5d-ecc8-071162df97a7@redhat.com>
References: <b32d0701-4399-9c5d-ecc8-071162df97a7@redhat.com>
Precedence: bulk
X-Mailing-List: lvm-devel@lists.linux.dev
List-Id: <lvm-devel.lists.linux.dev>
List-Subscribe: <mailto:lvm-devel+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:lvm-devel+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Mikulas Patocka <mpatocka@redhat.com>:
> Askar Safin requires swap and hibernation on the dm-integrity device mapper
> target because he needs to protect his data.

Hi, Mikulas, Milan and others.

I'm running swap on dm-integrity for 40 days.

It runs mostly without problems.

But yesterday my screen freezed for 4 minutes. And then continued to work
normally.

So, may I ask again a question: is swap on dm-integrity supposed to work
at all? (I. e. swap partition on top of dm-integrity partition on top of
actual disk partition.) (I'm talking about swap here, not about hibernation.)

Mikulas Patocka said here https://lore.kernel.org/all/3f3d871a-6a86-354f-f83d-a871793a4a47@redhat.com/ :

> Encrypted swap file is not supposed to work. It uses the loop device that 
> routes the requests to a filesystem and the filesystem needs to allocate 
> memory to process requests.

> So, this is what happened to you - the machine runs out of memory, it 
> needs to swap out some pages, dm-crypt encrypts the pages and generates 
> write bios, the write bios are directed to the loop device, the loop 
> device directs them to the filesystem, the filesystem attempts to allocate 
> more memory => deadlock.

Does the same apply to dm-integrity?

I. e. is it possible that write to dm-integrity will lead to allocation?

-- 
Askar Safin
