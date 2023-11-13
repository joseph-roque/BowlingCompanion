package ca.josephroque.bowlingcompanion.feature.datamanagement.ui

import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.runtime.Composable
import androidx.compose.ui.res.stringResource
import ca.josephroque.bowlingcompanion.core.designsystem.components.BackButton

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun DataExportTopBar(
	onAction: (DataExportUiAction) -> Unit,
) {
	TopAppBar(
		title = {
			Text(
				text = stringResource(R.string.data_export_title),
				style = MaterialTheme.typography.titleLarge,
			)
		},
		navigationIcon = {
			BackButton(onClick = { onAction(DataExportUiAction.BackClicked) })
		}
	)
}