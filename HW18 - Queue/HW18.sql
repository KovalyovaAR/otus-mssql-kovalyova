--select name, is_broker_enabled
--from sys.databases

--USE master
--ALTER DATABASE WideWorldImporters
--SET ENABLE_BROKER  WITH ROLLBACK IMMEDIATE;

--ALTER AUTHORIZATION    
--   ON DATABASE::WideWorldImporters TO [sa];

--ALTER DATABASE WideWorldImporters SET TRUSTWORTHY ON;

--������� ���� ���������
--USE WideWorldImporters
---- For Request
--CREATE MESSAGE TYPE
--[//WWI/SB/RequestMessage]
--VALIDATION=WELL_FORMED_XML; --������ ������������� ��� ��������, ��� ������ ������������� ���� XML(�� ����� ����� ���)
---- For Reply
--CREATE MESSAGE TYPE
--[//WWI/SB/ReplyMessage]
--VALIDATION=WELL_FORMED_XML; --������ ������������� ��� ��������, ��� ������ ������������� ���� XML(�� ����� ����� ���) 

----������� ��������
--CREATE CONTRACT [//WWI/SB/Contract]
--      ([//WWI/SB/RequestMessage]
--         SENT BY INITIATOR,
--       [//WWI/SB/ReplyMessage]
--         SENT BY TARGET
--      );

----������� ������� �������
--CREATE QUEUE TargetQueueWWI;
----� ������ �������
--CREATE SERVICE [//WWI/SB/TargetService]
--       ON QUEUE TargetQueueWWI
--       ([//WWI/SB/Contract]);

----�� �� ��� ����������
--CREATE QUEUE InitiatorQueueWWI;

--CREATE SERVICE [//WWI/SB/InitiatorService]
--       ON QUEUE InitiatorQueueWWI
--       ([//WWI/SB/Contract]);

--CREATE TABLE Sales.OrderCount(
--	customername nvarchar(500),
--	kol int,
--	datefrom date,
--	dateto date
--)

