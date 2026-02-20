const API_BASE = '/oncode';

const form = document.getElementById('payment-form');
const formTitle = document.getElementById('form-title');
const submitBtn = document.getElementById('submit-btn');
const cancelBtn = document.getElementById('cancel-btn');
const paymentIdField = document.getElementById('payment-id');
const amountField = document.getElementById('amount');
const fromAccountField = document.getElementById('from-account');
const toAccountField = document.getElementById('to-account');
const paymentsBody = document.getElementById('payments-body');
const statusDiv = document.getElementById('status');
const refreshBtn = document.getElementById('refresh-btn');

let editMode = false;

// Load payments on page load
document.addEventListener('DOMContentLoaded', loadPayments);
refreshBtn.addEventListener('click', loadPayments);
form.addEventListener('submit', handleSubmit);
cancelBtn.addEventListener('click', resetForm);

async function loadPayments() {
  paymentsBody.innerHTML = '<tr><td colspan="5" class="empty-state">Loading...</td></tr>';

  try {
    const res = await fetch(API_BASE + '/getpayments');
    if (!res.ok) throw new Error('Failed to load payments');
    const payments = await res.json();

    if (payments.length === 0) {
      paymentsBody.innerHTML = '<tr><td colspan="5" class="empty-state">No payments found</td></tr>';
      return;
    }

    paymentsBody.innerHTML = payments.map(function (p) {
      return '<tr>' +
        '<td>' + p.id + '</td>' +
        '<td>$' + p.amount.toFixed(2) + '</td>' +
        '<td>' + p.fromAccount + '</td>' +
        '<td>' + p.toAccount + '</td>' +
        '<td class="actions-cell">' +
          '<button class="btn btn-edit" onclick="editPayment(' + p.id + ', ' + p.amount + ', ' + p.fromAccount + ', ' + p.toAccount + ')">Edit</button>' +
          '<button class="btn btn-delete" onclick="deletePayment(' + p.id + ')">Delete</button>' +
        '</td>' +
      '</tr>';
    }).join('');
  } catch (err) {
    paymentsBody.innerHTML = '<tr><td colspan="5" class="empty-state">Error loading payments</td></tr>';
    showStatus(err.message, 'error');
  }
}

async function handleSubmit(e) {
  e.preventDefault();

  var payload = {
    amount: parseFloat(amountField.value),
    fromAccount: parseInt(fromAccountField.value),
    toAccount: parseInt(toAccountField.value)
  };

  try {
    var url, method;
    if (editMode) {
      url = API_BASE + '/updatepayment/' + paymentIdField.value;
      method = 'PUT';
    } else {
      url = API_BASE + '/addpayment';
      method = 'POST';
    }

    var res = await fetch(url, {
      method: method,
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(payload)
    });

    if (!res.ok) {
      var errData = await res.json();
      var msg = errData.errors ? errData.errors.join(', ') : errData.error || 'Request failed';
      throw new Error(msg);
    }

    showStatus(editMode ? 'Payment updated successfully' : 'Payment added successfully', 'success');
    resetForm();
    loadPayments();
  } catch (err) {
    showStatus(err.message, 'error');
  }
}

function editPayment(id, amount, fromAccount, toAccount) {
  editMode = true;
  paymentIdField.value = id;
  amountField.value = amount;
  fromAccountField.value = fromAccount;
  toAccountField.value = toAccount;
  formTitle.textContent = 'Edit Payment #' + id;
  submitBtn.textContent = 'Update Payment';
  cancelBtn.hidden = false;
  form.scrollIntoView({ behavior: 'smooth' });
}

async function deletePayment(id) {
  if (!confirm('Delete payment #' + id + '?')) return;

  try {
    var res = await fetch(API_BASE + '/deletepayment/' + id, { method: 'DELETE' });
    if (!res.ok) throw new Error('Failed to delete payment');
    showStatus('Payment #' + id + ' deleted', 'success');
    loadPayments();
  } catch (err) {
    showStatus(err.message, 'error');
  }
}

function resetForm() {
  editMode = false;
  form.reset();
  paymentIdField.value = '';
  formTitle.textContent = 'Add New Payment';
  submitBtn.textContent = 'Add Payment';
  cancelBtn.hidden = true;
}

function showStatus(message, type) {
  statusDiv.textContent = message;
  statusDiv.className = 'status ' + type;
  statusDiv.hidden = false;
  setTimeout(function () {
    statusDiv.hidden = true;
  }, 4000);
}
