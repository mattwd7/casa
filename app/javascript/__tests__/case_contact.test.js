/* eslint-env jest */
import { validateOccurredAt } from '../src/case_contact'

require('jest')

test("case_contact doesn't run on pages without case contact form", () => {
  // Set up our document body
  const name = 'hello'

  document.body.innerHTML = `<div>${name}</div>`

  require('../src/case_contact')

  expect(() => {
    window.onload()
  }).not.toThrow()
})

test("occured date field won't allow future dates and it will be set back to the current date", () => {
  const today = new Date()
  const afterTomorrow = new Date(Date.now() + 3600 * 1000 * 24 * 2)

  const todayString = today.toLocaleDateString('en-GB').split('/').reverse().join('-')
  const afterTomorrowString = afterTomorrow
    .toLocaleDateString('en-GB')
    .split('/')
    .reverse()
    .join('-')

  document.body.innerHTML = `<input value="${afterTomorrowString}" data-provide="datepicker" data-date-format="yyyy/mm/dd" class="form-control label-font-weight" type="text" name="case_contact[occurred_at]" id="case_contact_occurred_at">`

  const caseOccurredAt = document.getElementById('case_contact_occurred_at')

  validateOccurredAt(caseOccurredAt, 'focusout')

  expect(caseOccurredAt.value).toEqual(todayString)
})
