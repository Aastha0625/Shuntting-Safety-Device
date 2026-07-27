const ExcelJS = require('exceljs');
const PDFDocument = require('pdfkit-table');

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

    // Generate Mock Data Table based on report type
    // We'll keep it simple: Date, ID, Status, and some dynamic columns
    const tableData = {
      title: `${reportType || 'Data'} Results`,
      headers: ['Date', 'ID', 'Yard', 'Line', 'Status'],
      rows: [
        ['2026-07-25', '#S-1042', 'North Yard', 'Line 4', 'Completed'],
        ['2026-07-25', '#S-1039', 'South Yard', 'Line 2', 'Comm Loss'],
        ['2026-07-24', '#S-1021', 'East Yard', 'Line 1', 'Completed'],
        ['2026-07-23', '#S-0994', 'North Yard', 'Line 4', 'Completed'],
        ['2026-07-22', '#S-0988', 'West Yard', 'Line 1', 'Ongoing'],
      ],
    };

    if (reportType === 'Device Inventory') {
      tableData.headers = ['UUID', 'Device Type', 'Health', 'Maintenance Status'];
      tableData.rows = [
        ['LD-001', 'Loco Unit', 'Online', 'Good'],
        ['DE-042', 'Dead-End', 'Offline', 'Needs Repair'],
        ['PD-011', 'Portable', 'Online', 'Good'],
        ['CD-105', 'Coupling', 'Online', 'Good'],
      ];
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

    // Mock Data Headers
    let headers = ['Date', 'ID', 'Yard', 'Line', 'Status'];
    let rows = [
      ['2026-07-25', '#S-1042', 'North Yard', 'Line 4', 'Completed'],
      ['2026-07-25', '#S-1039', 'South Yard', 'Line 2', 'Comm Loss'],
      ['2026-07-24', '#S-1021', 'East Yard', 'Line 1', 'Completed'],
      ['2026-07-23', '#S-0994', 'North Yard', 'Line 4', 'Completed'],
      ['2026-07-22', '#S-0988', 'West Yard', 'Line 1', 'Ongoing'],
    ];

    if (reportType === 'Device Inventory') {
      headers = ['UUID', 'Device Type', 'Health', 'Maintenance Status'];
      rows = [
        ['LD-001', 'Loco Unit', 'Online', 'Good'],
        ['DE-042', 'Dead-End', 'Offline', 'Needs Repair'],
        ['PD-011', 'Portable', 'Online', 'Good'],
        ['CD-105', 'Coupling', 'Online', 'Good'],
      ];
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
