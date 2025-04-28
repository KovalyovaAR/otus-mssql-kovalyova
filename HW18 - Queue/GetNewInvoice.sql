CREATE PROCEDURE Sales.GetNewInvoice --����� �������� ��������� �� �������
AS
BEGIN

	DECLARE @TargetDlgHandle UNIQUEIDENTIFIER,
			@Message NVARCHAR(max),
			@MessageType Sysname,
			@ReplyMessage NVARCHAR(4000),
			@ReplyMessageName Sysname,
			@datefrom date,
			@dateto date,
			@cusname nvarchar(500),
			@kol int,
			@xml XML; 
	
	BEGIN TRAN; 

	--�������� ��������� �� ���������� ������� ��������� � �������
	RECEIVE TOP(1) 
		@TargetDlgHandle = Conversation_Handle, --�� �������
		@Message = Message_Body, --���� ���������
		@MessageType = Message_Type_Name --��� ���������
	FROM dbo.TargetQueueWWI; --��� ������� ������� �� ����� ���������

	SELECT @Message; --�� ��� �����

	SET @xml = CAST(@Message AS XML);

	--������� ��
	SELECT @datefrom = R.Iv.value('@datefrom','date')
	FROM @xml.nodes('/RequestMessage/Inv') as R(Iv);

	SELECT @dateto = R.Iv.value('@dateto','date')
	FROM @xml.nodes('/RequestMessage/Inv') as R(Iv);

	SELECT @cusname = R.Iv.value('@customername','nvarchar')
	FROM @xml.nodes('/RequestMessage/Inv') as R(Iv);

	SELECT @kol = R.Iv.value('@kol','int')
	FROM @xml.nodes('/RequestMessage/Inv') as R(Iv);

	INSERT INTO Sales.OrderCount
	VALUES (@cusname, @kol, @datefrom, @dateto)
	
	SELECT @Message AS ReceivedRequestMessage, @MessageType; --�� ��� �����
	
	-- Confirm and Send a reply
	IF @MessageType=N'//WWI/SB/RequestMessage' --���� ��� ��� ���������
	BEGIN
		SET @ReplyMessage =N'<ReplyMessage> Message received</ReplyMessage>'; --�����
	    --���������� ��������� ���� �����������, ��� ��� ������ ������
		SEND ON CONVERSATION @TargetDlgHandle
		MESSAGE TYPE
		[//WWI/SB/ReplyMessage]
		(@ReplyMessage);
		END CONVERSATION @TargetDlgHandle; --� ��� � ���������� �������!!! - ��� �������������(����-����) ��� ������ ����
		                                   --������ ��������� ������ �� �������� ������� ���������
	END 
	
	SELECT @ReplyMessage AS SentReplyMessage; --�� ��� ����� - ��� ��� �����

	COMMIT TRAN;
END