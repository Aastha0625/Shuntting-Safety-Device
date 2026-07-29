const ExcelJS = require('exceljs');
const PDFDocument = require('pdfkit-table');
const db = require('../config/db');

exports.generatePDF = async (req, res) => {
  try {
    const reportType = req.query.reportType;
    const filters = req.query.filters ? JSON.parse(req.query.filters) : {};
    
    // Create a new PDF document in portrait mode
    const doc = new PDFDocument({ margin: 30, size: 'A4', layout: 'portrait' });
    
    // Set headers so the client knows it's a PDF download
    res.setHeader('Content-Type', 'application/pdf');
    res.setHeader('Content-Disposition', `attachment; filename="${(reportType || 'Report').replace(/ /g, '_')}.pdf"`);
    
    // Pipe the PDF directly to the response
    doc.pipe(res);
    
    // Add Branding / Header
    doc.fontSize(20).text('SafeShunt - Reports & Audits', { align: 'center' });
    doc.moveDown();
    
    doc.fontSize(14).text(`Report Type: ${reportType || 'Standard'}`, { align: 'left' });
    doc.fontSize(10).text(`Generated On: ${new Date().toLocaleString()}`, { align: 'left' });
    doc.moveDown();

    // Add Filters Summary
    doc.fontSize(12).text('Applied Filters:', { underline: true });
    doc.fontSize(10);
    for (const [key, value] of Object.entries(filters || {})) {
       doc.text(`${key}: ${value}`);
    }
    doc.moveDown(2);

    let tableData = {
      title: `${reportType || 'Data'} Results`,
      headers: [],
      rows: []
    };

    if (reportType === 'Device Inventory') {
      tableData.headers = ['UUID', 'Type', 'Battery', 'Condition', 'Status'];
      const devices = await db.query('SELECT device_code, device_type, battery_level, condition_status, network_status FROM devices ORDER BY created_at DESC');
      tableData.rows = devices.rows.map(d => [d.device_code, d.device_type, d.battery_level || '--', d.condition_status, d.network_status]);
    } else {
      // Default to sessions
      tableData.headers = ['Date', 'Device', 'Employee', 'Status'];
      const sessions = await db.query(`
        SELECT da.issued_at, d.device_code, u.full_name, da.returned_at
        FROM device_assignments da
        JOIN devices d ON da.device_id = d.id
        JOIN users u ON da.employee_id = u.id
        ORDER BY da.issued_at DESC LIMIT 50
      `);
      tableData.rows = sessions.rows.map(s => [
        new Date(s.issued_at).toLocaleDateString(), 
        s.device_code, 
        s.full_name, 
        s.returned_at ? 'Finished' : 'Active'
      ]);
    }

    if (tableData.rows.length === 0) {
        tableData.rows = [['No data found', '', '', '', '']];
    }
    
    await doc.table(tableData, { 
      prepareHeader: () => doc.font("Helvetica-Bold").fontSize(10),
      prepareRow: (row, indexColumn, indexRow, rectRow, rectCell) => doc.font("Helvetica").fontSize(10)
    });
    
    doc.end();

  } catch (error) {
    console.error("PDF Generation Error:", error);
    if (!res.headersSent) {
       res.status(500).json({ error: 'Failed to generate PDF' });
    }
  }
};

exports.generateExcel = async (req, res) => {
  try {
    const reportType = req.query.reportType;
    const filters = req.query.filters ? JSON.parse(req.query.filters) : {};
    const safeReportType = reportType || 'Report';

    const workbook = new ExcelJS.Workbook();
    workbook.creator = 'SafeShunt';
    workbook.created = new Date();

    const sheet = workbook.addWorksheet(safeReportType.substring(0, 31)); // Max 31 chars for sheet name

    // Add Title
    sheet.addRow(['SafeShunt - Reports & Audits']);
    sheet.addRow([`Report Type: ${safeReportType}`]);
    sheet.addRow([`Generated On: ${new Date().toLocaleString()}`]);
    sheet.addRow([]);

    // Add Filters
    sheet.addRow(['Applied Filters:']);
    for (const [key, value] of Object.entries(filters || {})) {
       sheet.addRow([key, value]);
    }
    sheet.addRow([]);

    // Data from DB
    let headers = [];
    let rows = [];

    if (reportType === 'Device Inventory') {
      headers = ['UUID', 'Type', 'Battery', 'Condition', 'Status'];
      const devices = await db.query('SELECT device_code, device_type, battery_level, condition_status, network_status FROM devices ORDER BY created_at DESC');
      rows = devices.rows.map(d => [d.device_code, d.device_type, d.battery_level || '--', d.condition_status, d.network_status]);
    } else {
      // Default to sessions
      headers = ['Date', 'Device', 'Employee', 'Status'];
      const sessions = await db.query(`
        SELECT da.issued_at, d.device_code, u.full_name, da.returned_at
        FROM device_assignments da
        JOIN devices d ON da.device_id = d.id
        JOIN users u ON da.employee_id = u.id
        ORDER BY da.issued_at DESC LIMIT 50
      `);
      rows = sessions.rows.map(s => [
        new Date(s.issued_at).toLocaleDateString(), 
        s.device_code, 
        s.full_name, 
        s.returned_at ? 'Finished' : 'Active'
      ]);
    }

    if (rows.length === 0) {
        rows = [['No data found', '', '', '']];
    }

    // Add Header Row
    const headerRow = sheet.addRow(headers);
    headerRow.fill = {
      type: 'pattern',
      pattern: 'solid',
      fgColor: { argb: 'FF1A2A42' } // Navy blue
    };
    headerRow.font = { color: { argb: 'FFFFFFFF' }, bold: true };

    // Add Data
    sheet.addRows(rows);

    // Auto-fit columns (basic)
    sheet.columns.forEach(column => {
      column.width = 20;
    });

    res.setHeader('Content-Type', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
    res.setHeader('Content-Disposition', `attachment; filename="${safeReportType.replace(/ /g, '_')}.xlsx"`);

    await workbook.xlsx.write(res);
    res.end();

  } catch (error) {
    console.error("Excel Generation Error:", error);
    if (!res.headersSent) {
       res.status(500).json({ error: 'Failed to generate Excel' });
    }
  }
};
