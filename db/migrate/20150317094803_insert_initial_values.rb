class InsertInitialValues < ActiveRecord::Migration
  def change
    [
      ["OPN", "Open"],
      ["ASN", "Assigned"],
      ["RSL", "Being Resolved"],
      ["QCT", "Quality Control"],
      ["PMT", "Final Payment Calculation"],
      ["CFB", "Customer Feedback and Issue"],
      ["ROP", "Re-Open"],
      ["TBC", "To Be Closed"],
      ["CLS", "Closed"]
    ].each do |value|
      execute("insert into mst_spt_ticket_status (code,name) values ('#{value[0]}', '#{value[1]}')")
    end

    [
      ["CW", "Corporate warranty"],
      ["MW", "Manufacture warranty"],
      ["NW", "Non warranty"]
    ].each do |value|
      execute("insert into mst_spt_warranty_type (code, name) values ('#{value[0]}', '#{value[1]}')")
    end

    [
      ["IH", "In house"],
      ["OS", "On site"]
    ].each do |value|
      execute("insert into mst_spt_ticket_type (code, name) values ('#{value[0]}', '#{value[1]}')")
    end

    [
      ["PRQ", "Part Requested"],
      ["POD", "Part Ordered"],
      ["PRC", "Part Received"],
      ["ERQ", "Estimation Requested"],
      ["EST", "Estimated"],
      ["UDL", "Unit Delivered"],
      ["NAP", "Not Applicable"],
      ["FST", "First Level Resolved"],
      ["RSV", "Resolved"],
      ["TER", "Terminated"]
    ].each do |value|
      execute("insert into mst_spt_ticket_status_resolve (code, name) values ('#{value[0]}', '#{value[1]}')")
    end

    [
      ["OPN", "Open"],
      ["ASN", "Assigned"],
      ["RSL", "Being Resolved"],
      ["QCT", "Quality Control"],
      ["PMT", "Final Payment Calculation"],
      ["CFB", "Customer Feedback and Issue"],
      ["ROP", "Re-Open"],
      ["TBC", "To Be Closed"],
      ["CLS", "Closed"]
    ].each do |value|
      execute("insert into mst_spt_ticket_status (code, name) values ('#{value[0]}', '#{value[1]}')")
    end

    [
      ["IN", "Internal Repair"],
      ["EX", "External Repair"]
    ].each do |value|
      execute("insert into mst_spt_ticket_repair_type (code, name) values ('#{value[0]}', '#{value[1]}')")
    end

    [
      ["PH", "by phone"],
      ["CR", "carry in"],
      ["ML", "by mail"],
      ["FX", "fax"]
    ].each do |value|
      execute("insert into mst_spt_ticket_informed_method (code, name) values ('#{value[0]}', '#{value[1]}')")
    end

    [
      ["NAP", "Not Applicable"],
      ["USD", "Used"],
      ["UUS", "Un - Used"],
      ["DOA", "Dead on Arrival"],
      ["WSP", "Wrong Shipment"],
      ["WPB", "Wrong  Part in the Box"]
    ].each do |value|
      execute("insert into mst_spt_spare_part_status_use (code, name) values ('#{value[0]}', '#{value[1]}')")
    end

    [
      ["AD", "Advance payment"],
      ["FN", "Final payment"],
      ["OH", "Other"]
    ].each do |value|
      execute("insert into mst_spt_payment_received_type (code, name) values ('#{value[0]}', '#{value[1]}')")
    end

    [
      ["Extra Labour", 0],
    ].each do |value|
      execute("insert into mst_spt_payment_item (name, default_amount) values ('#{value[0]}', '#{value[1]}')")
    end

    [
      ["SW", "Softwear"],
      ["HW", "Hardwear"],
      ["NW", "Network"]
    ].each do |value|
      execute("insert into mst_spt_job_type (code, name) values ('#{value[0]}', '#{value[1]}')")
    end

    [
      ["RQS", "Requested"],
      ["EST", "Estimated"],
      ["CLS", "Closed"]
    ].each do |value|
      execute("insert into mst_spt_estimation_status (code, name) values ('#{value[0]}', '#{value[1]}')")
    end

    [
      ["Telephone", "0", "0"],
      ["Mobile", "1", "0"],
      ["Fax", "0", "0"],
      ["E-Mail", "0", "1"],
      ["Skype", "0", "0"],
    ].each do |value|
      execute("insert into mst_spt_customer_contact_type (name, mobile, email) values ('#{value[0]}', '#{value[1]}', '#{value[2]}')")
    end

    [
      ["ML", "Email"],
      ["SM", "SMS"],
      ["CL", "Call"],
      ["FX", "Fax"],
    ].each do |value|
      execute("insert into mst_spt_contact_type (code, name) values ('#{value[0]}', '#{value[1]}')")
    end

    [
      ["1", "Add ticket", "1", 0],
      ["2", "Assign Ticket", "2", 0],
      ["3", "Edit Ticket", "1", 0],
      ["4", "Assign Regional Support Center", "2", 0],
      ["5", "Start Action", "3", 0],
      ["6", "Re-Assign Request", "3", 0],
      ["7", "Terminate Job", "3", 0],
      ["8", "Hold", "3,9,12", 0],
      ["9", "Un Hold", "3,9,12", 0],
      ["10", "Edit Serial No Request", "3", 0],
      ["11", "Create FSR", "3", 0],
      ["12", "Edit FSR (Un Approved )", "3", 0],
      ["13", "Action Taken", "3", 0],
      ["14", "Request Spare Part from Manufacture", "3", 0],
      ["15", "Request Spare Part from Store", "3", 0],
      ["16", "Receive Spare Part by eng", "3", 0],
      ["17", "Return Part (Spare/Faulty)", "3", 0],
      ["18", "Request On Loan  Spare Part", "3", 0],
      ["19", "Terminate Spare Part", "3", 0],
      ["20", "HP Case Action", "3", 0],
      ["21", "Resolve the Job (Finish the Job)", "3", 0],
      ["22", "Deliver Unit", "3", 0],
      ["23", "Job Estimate Request", "3", 0],
      ["24", "Estimation Customer Aproved", "3", 0],
      ["25", "Recieve Unit", "3", 0],
      ["26", "Customer Inqure", "3", 0],
      ["27", "Job Estimation Done", "7", 0],
      ["28", "Invoice Advance Payment", "27,29", 0],
      ["29", "Delivere Unit To Supplier", "8", 0],
      ["30", "Collect Unit From Supplier", "8", 0],
      ["31", "Order Spare Part from Supplier", "9", 0],
      ["32", "Request To Warranty Extend", "9", 0],
      ["33", "Request To Estimate Parts", "9", 0],
      ["34", "Terminate Spare Part Order", "9", 0],
      ["35", "Edit Serial No", "9,12", 0],
      ["36", "Collect Spare part from Manufacture", "23", 0],
      ["37", "Receive Spare part from Manufacture", "10", 0],
      ["38", "Issue Spare part", "10", 0],
      ["39", "Warranty Extend", "12", 0],
      ["40", "Reject Warranty Extend", "12", 0],
      ["41", "Low Margin Job Estimate Approval", "19", 0],
      ["42", "Reject Returned Part", "11", 0],
      ["43", "Receive Returned part", "11,18", 0],
      ["44", "Close Event", "11,30", 0],
      ["45", "Part Bunndled", "21", 0],
      ["46", "Part Bunndl Delivered", "22", 0],
      ["47", "Approve Spare Part for Store", "16", 0],
      ["48", "Issue store Spare Part", "17", 0],
      ["49", "Approve On-Loan Part for Store", "16", 0],
      ["50", "Issue store On-Loan Part", "17", 0],
      ["51", "Receive On-Loan Part by eng", "3", 0],
      ["52", "Return On-Loan part", "3", 0],
      ["53", "Terminate On-Loan Part", "3", 0],
      ["54", "Receive Returned On-Loan part", "18", 0],
      ["55", "Request to Close Ticket", "3", 0],
      ["56", "Approve Close Ticket", "13", 0],
      ["57", "Quality Control Approved", "28", 0],
      ["58", "Customer Feedback", "14", 0],
      ["59", "Terminate FOC Job Approval", "31", 0],
      ["60", "Terminate Job Issue and Invoice", "24", 0],
      ["61", "Inform Customer", "14,24", 0],
      ["62", "POP Approval", "5", 0],
      ["63", "Estimate Job Final", "33", 0],
      ["64", "Reject Spare Part for Store", "16", 0],
      ["65", "Reject On-Loan Part for Store", "16", 0],
      ["66", "Reject Close Ticket", "13", 0],
      ["67", "Quality Control Rejected", "28", 0]
    ].each do |value|
      execute("insert into mst_spt_action (action_no, action_description, task_id, hide) values ('#{value[0]}', '#{value[1]}', '#{value[2]}', '#{value[3]}')")
    end

    [
      ["HDO", "Head Office"],
      ["BRN", "Branch"],
      ["DPT", "Department"],
      ["STR", "Store"]
    ].each do |value|
      execute("insert into mst_organizations_types (code, name) values ('#{value[0]}', '#{value[1]}')")
    end

    [
      ["Sri Lankan Rupees", "LKR", "Rs", "1"],
      ["United States Dollars", "USD", "$US", "0"]
    ].each do |value|
      execute("insert into mst_currency (currency, code, symbol, base_currency) values ('#{value[0]}', '#{value[1]}', '#{value[2]}', '#{value[3]}')")
    end

    [
      ["NAP", "Not Applicable"],
      ["RCD", "Received"],
      ["RPN", "Receive Pending"],
      ["APN", "Approval Pending"],
      ["LPN", "Pending From Local Provider"],
      ["APV", "Approved"],
      ["RJC", "Rejected"],
      ["UPD", "Updated"]
    ].each do |value|
      execute("insert into mst_spt_pop_status (code, name) values ('#{value[0]}', '#{value[1]}')")
    end

    [
      ["Check outer condition?", "Any damage in the casing?", 1, 1, 1],
      ["Any damage in the casing?", "TX", 1, 1, 0]
    ].each do |value|
      execute("insert into mst_spt_general_question (question, answer_type, active, action_id, compulsory) values ('#{value[0]}', '#{value[1]}', '#{value[2]}', '#{value[3]}', '#{value[4]}')")
    end

    [
      ["Mr."],
      ["Mrs."],
      ["Ms."],
      ["Miss."]
    ].each do |value|
      execute("insert into mst_title (title) values ('#{value[0]}')")
    end

  end
end
